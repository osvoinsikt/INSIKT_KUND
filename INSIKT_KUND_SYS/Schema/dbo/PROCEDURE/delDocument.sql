SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Tar bort dokumentet och antar att den som använt
				dokumentet redan tagit bort relationen till det.
				Om det inte finns någon referens kvar till
				dokumentets data, ta bort det också. Finns det minst
				en referens till dokumentets data kvar, låt det vara.
 #Used By:			-
 #Creator:			Adam Holmstrom
 #CreateDate:		140328
 #Modified by:		-
 #ModifiedDate:		-

 #Log:

********************************************************************/
CREATE PROCEDURE [dbo].[delDocument]
	@documentId int
AS
BEGIN
	SET NOCOUNT ON
	-- Spara undan vilka dokumentdata som refereras till
	SELECT dd.ID, dd.RemoteDocumentID
	INTO #dataForDocumentRevisions
	FROM DocumentRevision dr
		INNER JOIN DocumentData dd ON dr.DocumentDataID = dd.ID
	WHERE dr.DocumentID = @documentId
	ORDER BY dd.ID DESC

	-- Ta bort revisioner för dokumentet
	DELETE
	FROM DocumentRevision
	WHERE DocumentID = @documentId
	
	-- Ta bort dokumentlås
	DELETE dl
	FROM DocumentLock dl
	WHERE dl.DocumentID = @documentId

	-- Ta bort dokumentet
	DELETE
	FROM Document
	WHERE ID = @documentId

	-- Ta bort dokumentdata som inte används i revisioner från andra dokument
	DELETE dd
	FROM DocumentData dd
		INNER JOIN #dataForDocumentRevisions toRemove ON dd.ID = toRemove.ID
		LEFT JOIN DocumentRevision dr ON dd.ID = dr.DocumentDataID
	WHERE dr.RevisionID IS NULL

	SELECT DISTINCT RemoteDocumentID FROM #dataForDocumentRevisions
END
GO
