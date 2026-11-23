SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************
 #Desc: 		Selects all views
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Anders Holm
 #CreateDate:		061031
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE       Procedure dbo.selAllFCViews
		
AS

-- selAllFCViews

set nocount on

SELECT 	*
FROM FCView

GO
