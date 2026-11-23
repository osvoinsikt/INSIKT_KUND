SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Calle
-- Create date: 2017-06-08
-- Description:	Resets all approvals on activites and phases
-- =============================================
CREATE PROCEDURE [process].[Support_ResetApprovalOnInstance]
	@instanceId int,
	@onlyPhases bit = null
AS
BEGIN

	if @instanceId is not null
	begin 
		update s
		set s.FinishedBy = null, s.FinishedDate = null from process.ProcessInstanceActivityStep s join 
		process.ProcessInstanceActivity a on s.ProcessInstanceActivityID = a.ID join 
		process.ProcessInstancePhase p on a.ProcessInstancePhaseID = p.ID
		where p.ProcessInstanceID = @instanceId and a.ProcessTemplateActivityRevisionID in 
		(select MainDecisionPointActivityID from process.ProcessTemplatePhaseRevision pr join 
		process.ProcessInstance i on i.OriginalProcessTemplateRevisionID = pr.ProcessTemplateRevisionID
		where i.ID = @instanceId)

		update a
		set a.IsFinished = 0 from process.ProcessInstanceActivity a join 
		process.ProcessInstancePhase p on a.ProcessInstancePhaseID = p.ID
		where p.ProcessInstanceID = @instanceId and a.ProcessTemplateActivityRevisionID in 
		(select MainDecisionPointActivityID from process.ProcessTemplatePhaseRevision pr join 
		process.ProcessInstance i on i.OriginalProcessTemplateRevisionID = pr.ProcessTemplateRevisionID
		where i.ID = @instanceId)

		update process.ProcessInstancePhase 
		set IsFinished = 0
		where ProcessInstanceID = @instanceId

		if (@onlyPhases IS NULL OR @onlyPhases = 0)
		begin
			update s
			set s.FinishedBy = null, s.FinishedDate = null from process.ProcessInstanceActivityStep s join 
			process.ProcessInstanceActivity a on s.ProcessInstanceActivityID = a.ID join 
			process.ProcessInstancePhase p on a.ProcessInstancePhaseID = p.ID
			where p.ProcessInstanceID = @instanceId
		
			update a
			set a.IsFinished = 0 from process.ProcessInstanceActivity a join 
			process.ProcessInstancePhase p on a.ProcessInstancePhaseID = p.ID
			where p.ProcessInstanceID = @instanceId
		end
	end
END
GO
