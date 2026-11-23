SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Calle
-- Create date: 2017-07-05
-- Description:	A procedure that checks for processes which has something for the user to approve
-- Edit 1: 20200201 Anton vermcrantz Preformance updated changed CTE to tables
-- =============================================
CREATE PROCEDURE [dbo].[selProjectIDsWaitingOnProjectProcess]
	@FCTypeID int,
	@UserID int
AS
BEGIN
	--https://stackoverflow.com/questions/24794671/why-do-we-have-to-write-set-fmtonly-off-in-stored-procedures-when-using-entity-f
	SET FMTONLY OFF

	-- save the username of the users to skip a join on strings later. 
	declare @UserName nvarchar(255)
	select @UserName = UserName from UserSecurityGroup where UserID = @UserID

	-- Create a table that will hold all project IDs 
	create table #projectIDs (ProjectID int NOT NULL)

	-- Create a table that will hold the ids of the first non-finished phase for each project 
	create table #nextPhaseWithProject (PhaseID int, ProjectID int)
	insert into #nextPhaseWithProject (PhaseID, ProjectID)
	select 
		MIN(phase.ID) as PhaseID, MIN(p.ID) as ProjectID
	from FCProject p
		INNER JOIN FCProjectProcessInstanceRelation ppir
			ON ppir.FCProjectID = p.ID
		INNER JOIN process.ProcessInstancePhase phase 
			ON phase.ProcessInstanceID = ppir.ProcessInstanceID 
	WHERE 
		phase.IsFinished = 0 AND
		p.FCTypeID = @FCTypeID
	group by phase.ProcessInstanceID

	-- this table contains all activities with unfinished mandatory children
	create table #parentWithUnfinishedMandatory (ActivityID int)
	insert into #parentWithUnfinishedMandatory
	select
			parent.ID
		from #nextPhaseWithProject p
			INNER JOIN process.ProcessInstanceActivity parent 
				ON parent.ProcessInstancePhaseID = p.PhaseID
			LEFT JOIN process.ProcessInstanceActivity child
				ON parent.ID = child.ParentProcessInstanceActivityID
		WHERE 
		(
			child.IsMandatory = 1 AND
			child.IsFinished = 0 AND
			child.IsHidden = 0
		) 


	-- create a table contains all mandatory unfinished activity ids. 
	-- they are partitioned with row number by phase id and sorted so the main decision point is last
	-- this means that if MainDecisionPointActivityID is not null and row index is = 1. All mandatory activities 
	-- on this phase is finished.
	create table #blockedMainDecisionPoint (ActivityID int, RowIndex int, MainDecisionPointActivityID int)
	insert into #blockedMainDecisionPoint
	select
			a.ID as ActivityID, ROW_NUMBER() over (PARTITION by p.PhaseID ORDER BY phase.ID asc) as RowIndex, phase.MainDecisionPointActivityID as MainDecisionPointActivityID
		from #nextPhaseWithProject p
			INNER JOIN process.ProcessInstanceActivity a 
				ON a.ProcessInstancePhaseID = p.PhaseID
			LEFT JOIN process.ProcessTemplatePhaseRevision phase
				ON phase.MainDecisionPointActivityID = a.ProcessTemplateActivityRevisionID
		WHERE
			a.IsMandatory = 1 AND
			a.IsFinished = 0 AND
			a.IsHidden = 0 

	-- Create a table that will hold all activities that can be finished and has a role or user connection
		create table #relevantActivites (ActivityID int PRIMARY KEY, ProjectID int)

	-- this table contains all mandatory unfinished activity ids. 
	-- they are partitioned with row number by phase id and sorted so the main decision point is last
	-- this means that if MainDecisionPointActivityID is not null and row index is = 1. All mandatory activities 
	-- on this phase is finished.
	insert into #relevantActivites (ActivityID, ProjectID) 
	select distinct
		a.ID, p.ProjectID
	from #nextPhaseWithProject p
		INNER JOIN process.ProcessInstanceActivity a 
			ON a.ProcessInstancePhaseID = p.PhaseID
		INNER JOIN process.ProcessInstanceActivityResponsibleRelation rr
			ON rr.ProcessInstanceActivityID = a.ID 
	WHERE 
		a.IsFinished = 0 AND
		a.IsHidden = 0 AND
		not exists (select 1 from #parentWithUnfinishedMandatory b where b.ActivityID IS NOT NULL and b.ActivityID = a.ID) and
		not exists (select 1 from #blockedMainDecisionPoint b WHERE b.MainDecisionPointActivityID IS NOT NULL AND b.RowIndex <> 1 and a.ID = b.ActivityID)
		
	-- Add all project where the user is responsible for a activity
	INSERT INTO #projectIDs (ProjectID)
	select
		a.ProjectID 
	from #relevantActivites a
		INNER JOIN [process].ProcessInstanceActivityResponsibleRelation r 
			on a.ActivityID = r.ProcessInstanceActivityID AND r.ProcessInstanceActivityStepID IS NULL
	WHERE r.UserID = @UserID

	-- Create a table that will hold all roles for each project
	create table #projectAndRoles (ProjectID int, RoleID int)

	-- add roles connected to activities
	insert into #projectAndRoles (ProjectID, RoleID)
	select distinct
		a.ProjectID,
		r.RoleID
	from #relevantActivites a
		INNER JOIN [process].ProcessInstanceActivityResponsibleRelation r 
			on a.ActivityID = r.ProcessInstanceActivityID AND r.ProcessInstanceActivityStepID IS NULL
	WHERE r.RoleID IS NOT NULL

	-- Create a table that will list all un-finished steps by sort order as RowIndex
	-- This means the first un-finished step on each activity will have RowIndex = 1
	create table #activeStep (StepID int, RowIndex int, ProjectID int)
	insert into #activeStep
	select 
			s.ID, ROW_NUMBER() over (PARTITION by a.ActivityID ORDER BY s.[Order] asc) as RowIndex, a.ProjectID 
		from #relevantActivites a
			INNER JOIN process.ProcessInstanceActivityStep s 
				ON a.ActivityID = s.ProcessInstanceActivityID
			left JOIN process.ProcessInstanceActivityResponsibleRelation rr
				ON s.ID = rr.ProcessInstanceActivityStepID
		WHERE s.FinishedBy IS NULL

	-- Create a table that will hold all steps that can be finished and has a role or user connection 
	create table #relevantActivitySteps (StepID int, ProjectID int)

	insert into #relevantActivitySteps (StepID, ProjectID)
	SELECT StepID, ProjectID from #activeStep where RowIndex = 1

	-- Add all project where the user is responsible for a activity step
	INSERT INTO #projectIDs (ProjectID)
	select
		s.ProjectID
	from #relevantActivitySteps s
		INNER JOIN [process].ProcessInstanceActivityResponsibleRelation r 
			on s.StepID = r.ProcessInstanceActivityStepID
	WHERE r.UserID = @UserID

	-- add roles connected to steps
	insert into #projectAndRoles (ProjectID, RoleID)
	select distinct
		s.ProjectID,
		r.RoleID
	from #relevantActivitySteps s
		INNER JOIN [process].ProcessInstanceActivityResponsibleRelation r 
			on s.StepID = r.ProcessInstanceActivityStepID
	WHERE r.RoleID IS NOT NULL

	-- Add all project where user user is in a role that is responsible for a activity or activity step
	INSERT INTO #projectIDs (ProjectID)
	select 
		pr.ProjectID
	from #projectAndRoles pr
		join FCProjectPropertyFCRoleRelation fprr 
			on fprr.FCRoleID = pr.RoleID
        join FCProjectPropertyValue fppv 
			on fppv.ProjectPropertyID = fprr.FCProjectPropertyID
		join FCProjectProperty pp
			on pp.ID = fppv.ProjectPropertyID
	where pr.ProjectID = fppv.ProjectID
		and ((pp.Datatype = 'string' and fppv.ValueString = @UserName)
			or (pp.Datatype = 'numeric' and fppv.ValueNumeric = @UserID))

	select distinct ProjectID from #projectIDs
	

	DROP TABLE #activeStep
	DROP TABLE #blockedMainDecisionPoint
	DROP TABLE #parentWithUnfinishedMandatory
	DROP TABLE #relevantActivitySteps
	DROP TABLE #relevantActivites
	DROP TABLE #nextPhaseWithProject 
	DROP TABLE #projectAndRoles
	DROP TABLE #projectIDs

END
GO
