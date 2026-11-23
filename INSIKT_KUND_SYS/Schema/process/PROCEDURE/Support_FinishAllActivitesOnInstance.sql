SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Calle
-- Description:	Marks all activites on an process instance finsished except those who are on an phase
-- =============================================
CREATE PROCEDURE [process].[Support_FinishAllActivitesOnInstance]
	@instanceId int, -- process instance id
	@userId int -- the user to mark all as finished
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- set all steps finished except those who are on an phase
	update s
	set s.FinishedBy = @userId, s.FinishedDate = GETUTCDATE() from process.ProcessInstanceActivityStep s join 
	process.ProcessInstanceActivity a on s.ProcessInstanceActivityID = a.ID join 
	process.ProcessInstancePhase p on a.ProcessInstancePhaseID = p.ID
	where p.ProcessInstanceID = @instanceId and a.ProcessTemplateActivityRevisionID not in 
	(select MainDecisionPointActivityID from process.ProcessTemplatePhaseRevision pr join 
	process.ProcessInstance i on i.OriginalProcessTemplateRevisionID = pr.ProcessTemplateRevisionID
	where i.ID = @instanceId)

	-- set all activites finished except those who are on an phase
	update a
	set a.IsFinished = 1 from process.ProcessInstanceActivity a join 
	process.ProcessInstancePhase p on a.ProcessInstancePhaseID = p.ID
	where p.ProcessInstanceID = @instanceId and a.ProcessTemplateActivityRevisionID not in 
	(select MainDecisionPointActivityID from process.ProcessTemplatePhaseRevision pr join 
	process.ProcessInstance i on i.OriginalProcessTemplateRevisionID = pr.ProcessTemplateRevisionID
	where i.ID = @instanceId)

END
GO
