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
 #CreateDate:		040129
 #Modified by:		Daniel Hellström
 #ModifiedDate:		060308
 
 #Log:	060308	DH	Removed IsUser
	070317	ANHO	Added StartReportID
	070326	DH	Added DefaultDatasourceID
	080306	ANHO	Added useParentLevelBelow
	090611	ADHO	Added isViewerOnly
	160516	EMAH	Added SuperAdmin

********************************************************************/
CREATE          Procedure [dbo].[selUserByID]
	@iUserID int
AS
-- User Information
select 	[SID]
	,[UserName]
	,[FullName]
	,[UserID]
	,[StartReportID]
	,[DefaultDatasourceID]
	,[EmailAdress]
	,[SuperAdmin]
from [User]
where [UserID] = @iUserID

Return
GO
