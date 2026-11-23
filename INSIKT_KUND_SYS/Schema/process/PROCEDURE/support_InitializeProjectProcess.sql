SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Calle
-- Create date: 2016-07-05
-- Description:	A procedure that creates an process instance of 
--				a template process for a given project. 
-- @fcProjectID:	The project ID
-- @templateID:  	The ID of the process template from the table process.ProcessTemplate.ID
--					not from process.ProcessTempalteRevision. This procedure will always create an instance 
--					of the newest template revision. 
-- @userID:			This procedure can mark phases as completed, and for this it needs an
--					UserID to use for FinishedBy. Preferably use some INSIKT_ADMIN or the consultants on UserID	
-- @startTemplatePhaseID:	Optional parameter. If used it will complete all phases BEFORE the given phase ID. 	
--							Use the ProcessTemplatePhaseID and not ProcessTemplatePhaseRevisionID.		

-- LOG:
-- EMAH 2019-03-06	Fix procedure according to changes in process tables.
-- LINI 2019-06-12	Change to UTC timestamps.
-- =============================================
CREATE PROCEDURE [process].[support_InitializeProjectProcess]
	@fcProjectID int,
	@templateID int,
	@userID int,
	@startTemplatePhaseID int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Use the templateID to get the latest revision of the template
	declare @ProcessTemplateRevisionID int
	SELECT top 1 @ProcessTemplateRevisionID = ID from process.ProcessTemplateRevision where ProcessTemplateRevision.ProcessTemplateID = @templateID 
		and isdraft <> 1
		order by ID desc

	-- If the project does not have an instance, create one.
	IF NOT EXISTS(
		SELECT ProcessInstanceID
		FROM [dbo].[FCProjectProcessInstanceRelation]
		WHERE FCProjectID = @fcProjectID
	)
	BEGIN
		DECLARE @InstanceID int
		insert into process.ProcessInstance (OriginalProcessTemplateRevisionID, CreatedDate, CreatedBy, CurrentProcessTemplateRevisionID)
		values (@ProcessTemplateRevisionID, GETUTCDATE(), @userID, @ProcessTemplateRevisionID)
		set @InstanceID = SCOPE_IDENTITY()

		-- get all phases in to a cursor
		DECLARE @templatePhaseID int
		DECLARE phase_cursor CURSOR FOR
		select ID from process.ProcessTemplatePhaseRevision 
		where ProcessTemplatePhaseRevision.ProcessTemplateRevisionID = @ProcessTemplateRevisionID and
			ProcessTemplatePhaseRevision.IsDeleted = 0
		order by [Order]

		OPEN phase_cursor
		FETCH NEXT FROM phase_cursor INTO @templatePhaseID

		-- create a temporary table to store the activityTemplateID with related activityInstnaceID
		CREATE TABLE #ActivityTable (TemplateID int, InstanceID int)

		declare @phaseOrder int = 1
		-- for each phase
		WHILE @@FETCH_STATUS = 0
			BEGIN 
				
				-- add instance phase
				DECLARE @InstancePhaseID int
				insert into process.ProcessInstancePhase (ProcessTemplatePhaseRevisionID, ProcessInstanceID, IsFinished, [Order])
				values (@templatePhaseID, @InstanceID, 0, @phaseOrder)
				set @InstancePhaseID = SCOPE_IDENTITY()
				
				-- add all instance activities that don't have any parents
				INSERT INTO process.ProcessInstanceActivity (ProcessTemplateActivityRevisionID, ProcessInstancePhaseID, [Order], StartDate, EndDate, IsFinished, ParentProcessInstanceActivityID, Name, [Description], IsHidden, IsMandatory )
				SELECT ID, @InstancePhaseID, [Order], null, null, 0, null, null, null, 0, IsMandatory from process.ProcessTemplateActivityRevision 
				where 
					ProcessTemplatePhaseRevisionID = @templatePhaseID AND 
					ParentTemplateActivityRevisionID is null AND
					IsDeleted = 0

				-- add the templateID and instnaceID from the instance activities just added above 
				insert into #ActivityTable 
				SELECT ProcessTemplateActivityRevisionID, ID from process.ProcessInstanceActivity 
				where ProcessInstancePhaseID = @InstancePhaseID 
			
				-- adds all activity instances that are children 
				-- will loop until all subActivites have been added.  
				WHILE EXISTS ( SELECT 1 FROM #ActivityTable)
					BEGIN
						-- select the templateID and instanceID for the first instnaceActivity in the temp table.
						DECLARE @ActivityTemplateID int, @ActivityInstanceID int
						SELECT TOP 1 @ActivityTemplateID = TemplateID, @ActivityInstanceID = InstanceID FROM #ActivityTable
					
						-- delete the row selected above
						DELETE FROM #ActivityTable 
						WHERE TemplateID = @ActivityTemplateID and InstanceID = @ActivityInstanceID 

						-- insert all activities that have the current instanceActivity as parent. 
						INSERT INTO process.ProcessInstanceActivity (ProcessTemplateActivityRevisionID, ProcessInstancePhaseID, [Order], StartDate, EndDate, IsFinished, ParentProcessInstanceActivityID, Name, [Description], IsHidden, IsMandatory )
						SELECT ID, @InstancePhaseID, [Order], null, null, 0, @ActivityInstanceID, null, null, 0, IsMandatory from process.ProcessTemplateActivityRevision 
						where 
							ProcessTemplatePhaseRevisionID = @templatePhaseID AND 
							ParentTemplateActivityRevisionID = @ActivityTemplateID AND
							IsDeleted = 0
	
						-- add all subActivites inserted above to the temp table. 
						-- the the current instance activity didn't have any children, no activity will be added here 
						insert into #ActivityTable 
						SELECT ProcessTemplateActivityRevisionID, ID from process.ProcessInstanceActivity 
						where ProcessInstancePhaseID = @InstancePhaseID AND ParentProcessInstanceActivityID = @ActivityInstanceID

					END
			
				-- insert all activity steps 
				insert into process.ProcessInstanceActivityStep (ProcessInstanceActivityID, ProcessTemplateActivityStepRevisionID, IsHidden, FinishedDate, FinishedBy, [Order], Name, [Description])
				select ia.ID, ts.ID, 0, null, null, ts.[Order], ts.Name, ts.[Description] from process.ProcessTemplateActivityStepRevision ts 
				JOIN process.ProcessInstanceActivity ia on ts.ProcessTemplateActivityRevisionID = ia.ProcessTemplateActivityRevisionID 
				where 
					ia.ProcessInstancePhaseID = @InstancePhaseID and
					ts.IsDeleted = 0

				-- add role connections for all activites
				insert into process.ProcessInstanceActivityResponsibleRelation (ProcessInstanceActivityID, RoleID)
				SELECT 
					pia.ID, ptarr.RoleID
				FROM process.ProcessInstanceActivity pia
					INNER JOIN process.ProcessTemplateActivityResponsibleRelation ptarr 
						on ptarr.ProcessTemplateActivityRevisionID = pia.ProcessTemplateActivityRevisionID and
						ptarr.ProcessTemplateActivityStepRevisionID is null
				WHERE 
					pia.ProcessTemplateActivityRevisionID in (
						select ID from process.ProcessTemplateActivityRevision where ProcessTemplatePhaseRevisionID = @templatePhaseID
					) and
					pia.ProcessInstancePhaseID = @InstancePhaseID
	
				-- add role connections for all steps
				insert into process.ProcessInstanceActivityResponsibleRelation (ProcessInstanceActivityID, ProcessInstanceActivityStepID, RoleID)
				SELECT
					pia.ID, pias.ID, ptarr.RoleID
				FROM process.ProcessInstanceActivity pia
					left JOIN process.ProcessInstanceActivityStep pias 
						on pia.ID = pias.ProcessInstanceActivityID
					INNER JOIN process.ProcessTemplateActivityResponsibleRelation ptarr 
						on ptarr.ProcessTemplateActivityStepRevisionID = pias.ProcessTemplateActivityStepRevisionID and
						ptarr.ProcessTemplateActivityStepRevisionID is not null
				WHERE 
					pia.ProcessTemplateActivityRevisionID in (
						select ID from process.ProcessTemplateActivityRevision where ProcessTemplatePhaseRevisionID = @templatePhaseID
					) and
					pia.ProcessInstancePhaseID = @InstancePhaseID

				set @phaseOrder = @phaseOrder + 1 
				-- next phase
				FETCH NEXT FROM phase_cursor INTO @templatePhaseID
			END
		
		DROP TABLE #ActivityTable
		CLOSE phase_cursor
		DEALLOCATE phase_cursor

		-- create a temporary table to store the IDs of the instance phases to be completed
		CREATE TABLE #PhaseToComplete(PhaseInstanceID int)

		-- use @startTemplatePhaseID to get the order of the start instance phase
		DECLARE @startInstancePhaseOrder int
		select @startInstancePhaseOrder = tp.[Order] from process.ProcessTemplatePhaseRevision tp 
		join process.ProcessInstancePhase ip on ip.ProcessTemplatePhaseRevisionID = tp.ID
		where tp.ProcessTemplatePhaseID = @startTemplatePhaseID

		-- add the IDs of all phases that come before @startInstancePhaseID
		insert into #PhaseToComplete
		select ip.ID from process.ProcessInstancePhase ip 
		join process.ProcessTemplatePhaseRevision tp on tp.ID = ip.ProcessTemplatePhaseRevisionID
		where ProcessInstanceID = @InstanceID and tp.[Order] < @startInstancePhaseOrder

		WHILE EXISTS ( SELECT 1 FROM #PhaseToComplete)
			BEGIN
				-- current phase instance ID
				DECLARE @PhaseIDToCompelete int
				SELECT TOP 1 @PhaseIDToCompelete = PhaseInstanceID from #PhaseToComplete

				-- delete from #PhaseToComplete
				DELETE FROM #PhaseToComplete
				WHERE PhaseInstanceID = @PhaseIDToCompelete

				-- complete steps
				UPDATE step
				SET FinishedDate = GETUTCDATE(), FinishedBy = @userID
				FROM process.ProcessInstanceActivityStep step 
				join process.ProcessInstanceActivity activity on activity.ID = step.ProcessInstanceActivityID
				join process.ProcessInstancePhase phase on phase.ID = activity.ProcessInstancePhaseID
				where phase.ID = @PhaseIDToCompelete

				-- complete activities
				UPDATE activity
				set 
					StartDate = GETUTCDATE(), 
					EndDate = GETUTCDATE(), 
					IsFinished = 1, 
					IsHidden = CASE  
                        WHEN phaseRev.ID is null THEN 1 -- only hide activites that is't the phase activity
                        ELSE 0
                    END 
				from process.ProcessInstanceActivity activity
					join process.ProcessInstancePhase phase 
						on phase.ID = activity.ProcessInstancePhaseID
					join process.ProcessTemplateActivityRevision activityRev 
						on activityRev.ID = activity.ProcessTemplateActivityRevisionID
					left join process.ProcessTemplatePhaseRevision phaseRev
						on phaseRev.MainDecisionPointActivityID = activityRev.ID
				where phase.ID = @PhaseIDToCompelete 

				-- complete phase
				UPDATE process.ProcessInstancePhase
				set IsFinished = 1
				where ID = @PhaseIDToCompelete

			END
	
		DROP TABLE #PhaseToComplete

		-- add a relation to the project 
		insert into dbo.FCProjectProcessInstanceRelation (FCProjectID, ProcessInstanceID, IsActive)
		values (@fcProjectID, @InstanceID, 1)
	END -- End of IF EXISTS
END -- End of procedure
GO
