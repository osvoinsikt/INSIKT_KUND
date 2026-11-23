SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Calle
-- Create date: 2018-18-06
-- Description:	Procedur som tar bort draft-revisionen från en mall
-- =============================================
CREATE PROCEDURE [process].[deleteDraftFromTemplate]
	@processTemplateId int
AS
BEGIN

	DECLARE @processTemplateRevisionId int

	select @processTemplateRevisionId = ID from process.ProcessTemplateRevision 
	where 
		ProcessTemplateID = @processTemplateId and
		IsDraft = 1

	if @processTemplateRevisionId is not null
	begin
		
		create table #ActivityRevisionIds (ID int)

		-- good to have
		insert into #ActivityRevisionIds
		select a.ID 
		from process.ProcessTemplateActivityRevision a
			join process.ProcessTemplatePhaseRevision p
				on a.ProcessTemplatePhaseRevisionID = p.ID
		where 
			p.ProcessTemplateRevisionID = @processTemplateRevisionId
		
		-- Delete external tables
		-- Documents
		create table #DocumentIds (DocumentID int)

		insert into #DocumentIds 
		select 
			DocumentID 
		from FCProjectProcessTemplateDocument
		where 
			ProcessTemplateRevisionID = @processTemplateRevisionId

		delete from FCProjectProcessTemplateDocument
		where 
			ProcessTemplateRevisionID = @processTemplateRevisionId

		declare @DocumentId int

		WHILE EXISTS ( SELECT 1 FROM #DocumentIds)
		begin
			select top 1 @DocumentId = DocumentID from #DocumentIds
			exec dbo.delDocument @DocumentId
			delete from #DocumentIds where DocumentID = @DocumentId
		end

		-- Triggers
		delete from FCProjectCalcTriggerActionRelation where FCProjectCalcTriggerID in (
			select t.ID from FCProjectCalcTrigger t 
				join #ActivityRevisionIds a on t.ProcessTemplateActivityRevisionID = a.ID
		)

		delete from FCProjectCalcTrigger 
		where ProcessTemplateActivityRevisionID in (select ID from #ActivityRevisionIds)

		-- process tables
		-- Constraints
		delete from process.ProcessTemplateActivityConstraintRelation
		where ProcessTemplateActivityRevisionID in (select ID from #ActivityRevisionIds)

		-- ResponsibleRelation
		delete from process.ProcessTemplateActivityResponsibleRelation
		where ProcessTemplateActivityRevisionID in (select ID from #ActivityRevisionIds)

		-- Step
		delete from process.ProcessTemplateActivityStepRevision
		where ProcessTemplateActivityRevisionID in (select ID from #ActivityRevisionIds)

		declare @temporaryActivityId int
		select top 1 @temporaryActivityId = ID from process.ProcessTemplateActivityRevision

		-- Clear phase main decision point 
		update process.ProcessTemplatePhaseRevision
		set MainDecisionPointActivityID = @temporaryActivityId
		where ProcessTemplateRevisionID = @processTemplateRevisionId

		-- Activity
		delete from process.ProcessTemplateActivityRevision
		where ID in (select ID from #ActivityRevisionIds)

		-- Phase
		delete from process.ProcessTemplatePhaseRevision
		where ProcessTemplateRevisionID = @processTemplateRevisionId

		-- Revision
		delete from process.ProcessTemplateRevision
		where ID = @processTemplateRevisionId

		drop table #DocumentIds
		drop table #ActivityRevisionIds
	end
END
GO
