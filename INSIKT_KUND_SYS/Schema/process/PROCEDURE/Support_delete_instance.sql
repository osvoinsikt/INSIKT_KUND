SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Stored Procedure

-- =============================================
-- Author:		<Calle>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [process].[Support_delete_instance]
	@instanceId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN tran

	select doc.ID into #tempDocIds from dbo.Document as doc
	join dbo.FCProjectProcessInstanceDocument as instancedoc on doc.ID = instancedoc.DocumentID
	where ProcessInstanceID = @instanceId


	DELETE from dbo.FCProjectProcessInstanceDocument where ProcessInstanceID = @instanceId

	DECLARE @docID int
	WHILE exists (SELECT 1 FROM #tempDocIds )
	BEGIN
		SELECT @docID = id from #tempDocIds
		exec dbo.delDocument @docID
		DELETE FROM #tempDocIds WHERE ID = @docID
	END

	DELETE FROM process.ProcessInstanceSyncLog where ProcessInstanceID = @instanceId

	delete from process.ProcessCommentUserReadRelation
				where ProcessCommentID in (select ID from process.ProcessComment where ProcessInstanceID = @instanceId)

	delete from process.ProcessComment
				where ProcessInstanceID = @instanceId

	delete rel from process.ProcessInstanceActivityResponsibleRelation as rel
				join process.ProcessInstanceActivity as a on rel.ProcessInstanceActivityID = a.ID
				join process.ProcessInstancePhase as p on a.ProcessInstancePhaseID = p.ID
				where p.ProcessInstanceID = @instanceId

	delete s from process.ProcessInstanceActivityStep as s
				join process.ProcessInstanceActivity as a on s.ProcessInstanceActivityID = a.ID
				join process.ProcessInstancePhase as p on a.ProcessInstancePhaseID = p.ID
				join process.ProcessInstance as i on p.ProcessInstanceID = i.ID
				where i.ID = @instanceId

	delete a from process.ProcessInstanceActivity as a
				join process.ProcessInstancePhase as p on a.ProcessInstancePhaseID = p.ID
				join process.ProcessInstance as i on p.ProcessInstanceID = i.ID
				where i.ID = @instanceId

	delete p from process.ProcessInstancePhase as p
				join process.ProcessInstance as i on p.ProcessInstanceID = i.ID
				where i.ID = @instanceId


	delete from dbo.FCProjectProcessInstanceRelation
				where ProcessInstanceID = @instanceId

	delete from process.ProcessInstance
				where ID = @instanceId
	commit
END
GO
