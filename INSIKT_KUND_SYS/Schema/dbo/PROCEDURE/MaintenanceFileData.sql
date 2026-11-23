SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Check for if there exists more then 10 files of any type. If there exists more 
				remove extra files that are more the 90 days old.
				The documents will not be removed but the filedata. Becuase of keys 
				the rows in documentRevision will also be deleted.
 #Used By:			-
 #Creator:			Anton Vermcrantz
 #CreateDate:		190711
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE PROCEDURE [dbo].[MaintenanceFileData]
	
AS
BEGIN
	DECLARE @90DaysAgo AS DATE = (GETUTCDATE() - 90)
	-- DROP DOCUMENTS FROM FileUpload
	DECLARE @documentId INT
	CREATE TABLE #FileTypes (TypeID INT)
	INSERT INTO #FileTypes
	SELECT ID from FileUploadType

	CREATE TABLE #DocumentToDateCheck (DocumentID INT)

	DECLARE @TypeID INT

	--Get DocumentIDs to check date for
	WHILE exists (SELECT * FROM #FileTypes)
	BEGIN
		CREATE TABLE #10NewestDocumentPerType (ID INT)

		SELECT TOP 1 @TypeID = TypeID from #FileTypes

		--Insert the 10 latest document of current type in #10NewestDocumentPerType
		INSERT INTO #10NewestDocumentPerType
		SELECT TOP 10 ID FROM FileUpload
		WHERE 
			FileTypeID = @TypeID
		ORDER BY ID DESC

		--Insert the documents of current type who is not the 10 latest in  #DocumentToDateCheck
		INSERT INTO #DocumentToDateCheck
		SELECT DocumentID from FileUpload
		WHERE
			FileTypeID = @TypeID and
			ID not in (SELECT ID FROM #10NewestDocumentPerType)
		
		DELETE FROM #FileTypes WHERE TypeID = @TypeID 
		DROP TABLE #10NewestDocumentPerType
	END

	
	-- Check if the documents in #DocumentToDateCheck is older the 90 days.
	CREATE TABLE #DocumentsRevisionToDelete (DocumentID INT) 
	WHILE exists (SELECT * FROM #DocumentToDateCheck)
	BEGIN
		SELECT TOP 1 @documentId = DocumentId FROM #DocumentToDateCheck

		INSERT INTO #DocumentsRevisionToDelete
			SELECT ID FROM Document
				WHERE @documentId = ID AND
				UploadedDate < @90DaysAgo

		DELETE FROM #DocumentToDateCheck WHERE DocumentID = @documentId
	END

	-- DELETE in DocumentRevision and Save DocumentDataID
	-- This is needed becuase of foreign keys.
	CREATE TABLE #DocumentDataToDelete (DocumentDataID INT) 
	WHILE exists (SELECT * FROM #DocumentsRevisionToDelete)
	BEGIN
		SELECT TOP 1 @documentId = DocumentId FROM #DocumentsRevisionToDelete

		INSERT INTO #DocumentDataToDelete
			SELECT DocumentDataID FROM DocumentRevision
				WHERE @documentId = DocumentID 
		
		DELETE FROM DocumentRevision
		WHERE @documentId = DocumentID 

		DELETE FROM #DocumentsRevisionToDelete WHERE DocumentID = @documentId
	END

	-- DELETE in DocumentData from #DocumentDataToDelete
	DECLARE @documentDataId INT
	WHILE exists (SELECT * FROM #DocumentDataToDelete)
	BEGIN
		SELECT TOP 1 @documentDataId = DocumentDataID FROM #DocumentDataToDelete
		
		DELETE FROM DocumentData
			WHERE @documentDataId = ID 

		DELETE FROM #DocumentDataToDelete WHERE DocumentDataID = @documentDataId
	END

	DROP TABLE #DocumentToDateCheck
	DROP TABLE #FileTypes
	DROP TABLE #DocumentsRevisionToDelete
	DROP TABLE #DocumentDataToDelete

			

END
GO
