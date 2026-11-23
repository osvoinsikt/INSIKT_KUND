SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Insert login entry
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		040203
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE Procedure [dbo].[registerLogin]
	@userID varchar(50)
	,@impersonatedBy int = null
	,@nID int output

AS
BEGIN
	set nocount on

	insert into SessionLog
		(
		UserID
		,dtLoginTime
		,ImpersonatedBy
		)
	Values
		(
		@userID
		,getutcdate()
		,@impersonatedBy
		)
	
	set @nID = SCOPE_IDENTITY()
END
GO
