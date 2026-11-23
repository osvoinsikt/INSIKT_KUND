SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc:				Select the domain based on username
 #Owner:			DBO
 #Creator:			Daniel Hellström
 #CreateDate:		060627
 #Modified by:		EMAH
 #ModifiedDate:		220309

 #Log:
	- 220309 EMAH Update username parameter to 255 chars (same as in dbo.UserSecurityGroup)
********************************************************************/

CREATE Procedure [dbo].[selUserDomain]
                      @vsUser varchar(255)
AS

-- selUserDomain 'dahe'
-- User Information

select [UserID],DomainName
from [User]
where [UserName] like '%\' + @vsUser or [UserName] = @vsUser

Return
GO
