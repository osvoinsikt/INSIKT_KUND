SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 			Skapar ett nytt dokument och returnerar dess 
					ID nummer.	
 #Used By:			-
 #Creator:			Adam Holmstrom
 #CreateDate:		140330
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE PROCEDURE [dbo].[insDocument] 
(
	@name nvarchar(250),
	@fileType varchar(5),
	@data varbinary(max),
	@uploadedBy int,
	@uploadedDate datetime = null
)
AS
BEGIN
	DECLARE 
		@documentID int,
		@revisionID int,
		@dataID int

	SELECT @fileType = ISNULL(@fileType, dbo.fn_GetFileExtension(@name))

	-- Skapa dokument
	INSERT INTO Document(Name, FileType, [GUID], UploadedBy, UploadedDate)
	VALUES(@name, @fileType, newid(), @uploadedBy, ISNULL(@uploadedDate, GETUTCDATE()))

	SET @documentID = @@IDENTITY

	-- Skapa revision
	SET @revisionID = 1
	INSERT INTO DocumentRevision(DocumentID, RevisionID, IsLatestRevision, UploadedBy, UploadedDate)
	VALUES(@documentID, 1, 1, @uploadedBy, ISNULL(@uploadedDate, GETUTCDATE()))

	-- Skapa dokumentdata
	INSERT INTO DocumentData(FileType, Data)
	VALUES(@fileType, @data)

	SET @dataID = @@IDENTITY

	-- Koppla revision till data
	UPDATE DocumentRevision
	SET DocumentDataID = @dataID
	WHERE 
		DocumentID = @documentID AND
		RevisionID = @revisionID

	RETURN @documentID

END
GO
