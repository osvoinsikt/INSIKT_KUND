SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Selects a specific category
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		040812
 #Modified by:		Johan Kultti
 #ModifiedDate:		100224
 
 #Log:
	100224	JOKU	Modified proc so only active categories are selected

********************************************************************/
CREATE       Procedure [dbo].[selCategory]
		@iCategoryID int
AS

-- selCategory 

set nocount on

select 	c.[ID]
	,c.[Name]
	,c.[ParentID] 
	,c.[Description]
	,c.[ParentID]
	,c.isCommon
	,c.[User]
	,c.isOpenSave
	,c.Restricted

from [Category] as c

where c.[ID] = @iCategoryID
	AND c.[Inactive] = 0
GO
