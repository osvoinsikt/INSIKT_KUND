SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Selects a single user
 #Used By:		-
 #InParam:		-
 #ResultSet:		Default Hierarchies set for user
 #
 #Returns:		Userinfo as outputparameters
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		031001
 #Modified by:		EMAH
 #ModifiedDate:		220309
 
 #Log:
	- 220309 EMAH Update username parameter to 255 chars (same as in dbo.UserSecurityGroup)
********************************************************************/
CREATE         Procedure [dbo].[selUserByUserName]
	@vsUser varchar(255)
		
AS

declare @userId int
select @userId = UserID
from [User]
where [UserName] = @vsUser

select *
from [User]
where UserID = @userId

select *
from UserSecurityGroupAuthenticationDevice
where UserID = @userId
GO
