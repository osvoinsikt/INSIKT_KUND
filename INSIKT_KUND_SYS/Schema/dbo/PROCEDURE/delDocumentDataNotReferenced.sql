SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 			Tar bort alla poster från DocumentData som inte 
					refereras till av någon dokumentrevision.
 #Used By:			-
 #Creator:			Adam Holmstrom
 #CreateDate:		140327
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE PROCEDURE [dbo].[delDocumentDataNotReferenced] AS
BEGIN
	DELETE FROM dd
	FROM DocumentData dd
		LEFT JOIN DocumentRevision dr ON dd.ID = dr.DocumentDataID
	WHERE dr.RevisionID IS NULL
END
GO
