SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Removes documents that don#t have any reference and are more then week old.
 #Used By:			-
 #Creator:			Anton Vermcrantz
 #CreateDate:		190711
 #Modified by:		Mathias Hedqvist
 #ModifiedDate:		250121
 
 #Log:

********************************************************************/
CREATE PROCEDURE [dbo].[MaintenanceDocument]
	
AS
BEGIN
	DECLARE @1WeekAgo AS DATETIME = (GETUTCDATE() - 7 )

	-- DROP UNREFERENCED DOCUMENTS
	-- Create a Temp Table and save all the references of Check for all DocumentID 
	CREATE TABLE #DocumentsToKeep 
	(
		DocumentID INT
	)
	INSERT INTO #DocumentsToKeep
		SELECT DocumentID FROM FileUpload
		UNION
		SELECT DocumentID FROM CellCommentDocument
		UNION
		SELECT DocumentID FROM FCInstructionDocument 
		UNION
		SELECT DocumentID FROM FCProcessCommentDocument  
		UNION
		SELECT DocumentID FROM FCProjectDocument 
		UNION
		SELECT DocumentID FROM FCProjectProcessTemplateDocument 
		UNION
		SELECT DocumentID FROM FCProjectProcessInstanceDocument
		UNION
		SELECT DocumentID FROM MailLogDocumentRelation
		UNION
		SELECT DocumentID FROM SubscriptionDocumentRelation
		UNION
		SELECT DocumentID FROM FCObjectDocument
        UNION
        SELECT DocumentID FROM scorecard.Document
	
	CREATE TABLE #DocumentsToDelete 
	(
		DocumentID INT
	)
	INSERT INTO #DocumentsToDelete
	SELECT Document.ID 
		FROM Document LEFT JOIN #DocumentsToKeep
			ON Document.ID = #DocumentsToKeep.DocumentID
	WHERE 
		#DocumentsToKeep.DocumentID IS NULL AND
		Document.UploadedDate < @1WeekAgo

	DECLARE @documentId INT
	WHILE exists (SELECT * FROM #DocumentsToDelete)
	BEGIN
		SELECT top 1 @documentId = DocumentId FROM #DocumentsToDelete

		EXEC delDocument @documentId

		DELETE FROM #DocumentsToDelete WHERE DocumentID = @documentId
	END

	DROP TABLE #DocumentsToKeep
	DROP TABLE #DocumentsToDelete
				

END

GO
