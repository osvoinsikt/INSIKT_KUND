SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO





/*******************************************************************
 #Desc: 		Select all FCTypes
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Anders Holm
 #CreateDate:		110509
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:	110509	ANHO	Created

********************************************************************/
CREATE            Procedure [dbo].[selAllFCTypes]
	
AS

-- [selAllFCTypes]

SELECT 	*
FROM 	FCType
Order by [ID]





GO
