SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*******************************************************************
 #Desc: 		Get a users language id
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Johan Kultti
 #CreateDate:		061108
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE    PROCEDURE [dbo].[getUserLanguageID] 
		@UserID int
AS
BEGIN
	SET NOCOUNT ON
				
	SELECT LangID FROM [User] WHERE [UserID] = @UserID

END




GO
