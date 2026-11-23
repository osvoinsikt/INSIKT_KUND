SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*******************************************************************
 #Desc: 		Selects all users
 #Used By:		-
 #InParam:		-
 #ResultSet:		All fieldsfrom user
 #
 #Returns:		Userinfo as outputparameters
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		040129
 #Modified by:		Andreas Nording
 #ModifiedDate:		080520
 
 #Log:
 # 080520: Order by FullName
********************************************************************/
CREATE        Procedure [dbo].[selAllUsers]
	
AS

-- User Information
select *

from [User]

order by FullName

GO
