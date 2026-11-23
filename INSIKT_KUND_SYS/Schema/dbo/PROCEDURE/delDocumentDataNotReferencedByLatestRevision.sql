SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 			Tar bort alla poster från DocumentData som inte 
					refereras till någon nuvarande dokumentrevision.
 #Used By:			-
 #Creator:			Adam Holmstrom
 #CreateDate:		140327
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE PROCEDURE [dbo].[delDocumentDataNotReferencedByLatestRevision] AS
BEGIN
	UPDATE DocumentRevision
	SET DocumentDataID = NULL
	WHERE IsLatestRevision = 0

	EXEC delDocumentDataNotReferenced
END
GO
