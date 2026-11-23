SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 			Selects all FCTypeGroups
 #Used By:			-
 #InParam:			-
 #ResultSet:		-
 #
 #Returns:			-
 #Owner:			DBO
 #Creator:			Anders Holm
 #CreateDate:		110531
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:
	110517	ANHO	Created, rewritten from selFCSheets
	160321	EMAH	Added column IsPrimary that inidicates which type is primary in the group
	160610	EMAH	Returns SortOrder

********************************************************************/
CREATE         Procedure [dbo].[selFCTypeGroups]
		
AS

-- [selFCTypeGroups]

SELECT DISTINCT ID as GroupID , Caption FROM FCTypeGroup

SELECT 	tg.*,
		tgr.FCTypeID,
		tgr.SortOrder,
		tgr.IsPrimary,
		tgr.SortOrder

FROM FCTypeGroup tg
INNER JOIN [FCTypeGroupRelation] tgr on tg.[ID] = tgr.GroupID 
ORDER BY tgr.SortOrder
/* ------------------------------- */
GO
