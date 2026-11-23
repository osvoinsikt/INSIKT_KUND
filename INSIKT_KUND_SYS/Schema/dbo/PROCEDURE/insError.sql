SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Insert an error Event
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:	2004-09-16
 #Modified by:	segr
 #ModifiedDate:	2013-11-25
 
 #Log:
   2013-11-25	Lade till valfri parameter för nivå
   2017-01-03	Tar in nivåID istället för nummer.

********************************************************************/
CREATE PROCEDURE [dbo].[insError]
	@vsUserName varchar(50),
	@vsStackTrace nvarchar(max),
	@vsErrorMessage nvarchar(max),
	@iErrorLevelID int = NULL
AS
	INSERT INTO [ErrorLog] ([EventDate], [UserName], [StackTrace], [ErrorMessage], [ErrorLogLevelID])
		VALUES(getutcdate(), @vsUserName, @vsStackTrace, @vsErrorMessage, @iErrorLevelID)
GO
