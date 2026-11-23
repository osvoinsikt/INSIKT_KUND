SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*******************************************************************
 #Desc: 			Selects all FCSheets
 #Used By:			-
 #InParam:			-
 #ResultSet:		-
 #
 #Returns:			-
 #Owner:			DBO
 #Creator:			Daniel Hellström
 #CreateDate:		110517
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:
	110517	DAHE	Created

********************************************************************/
CREATE         Procedure [dbo].[selFCSheets]
		
AS

-- selFCheets

set nocount on

SELECT 	*

FROM [FCTypeGroupRelation]
ORDER BY SortOrder

GO
