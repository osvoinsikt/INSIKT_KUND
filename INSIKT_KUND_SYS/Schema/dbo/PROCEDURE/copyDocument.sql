SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 			Kopierar ett dokument inklusive revisioner men
					pekar data-objektet så att det inte kopieras.
					D v s den stora delen av ett dokument kopieras 
					inte utan återanvänds.	
 #Used By:			-
 #Creator:			Adam Holmstrom
 #CreateDate:		140401
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE PROCEDURE [dbo].[copyDocument] 
(
	@documentID int
)
AS
BEGIN
	-- Skapa dokument
	INSERT INTO Document(Name, FileType, [GUID], UploadedBy, UploadedDate)
	SELECT Name, FileType, newid(), UploadedBy, UploadedDate
	FROM Document
	WHERE ID = @documentID

	DECLARE @copyDocumentID int
	SET @copyDocumentID = @@IDENTITY

	-- Skapa revision
	INSERT INTO DocumentRevision(DocumentID, RevisionID, IsLatestRevision, UploadedBy, UploadedDate, DocumentDataID)
	SELECT @copyDocumentID, RevisionID, IsLatestRevision, UploadedBy, UploadedDate, DocumentDataID
	FROM DocumentRevision
	WHERE DocumentID = @documentID

	RETURN @copyDocumentID

END
GO
