SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Sätter ElementKey i CellCommentDimension utifrån FullMemberName.
				Det görs genom att försöka parsa unika namnet och ta sista siffran.
				Det bör fungera för normala hierarkier, men dock inte för all-nivån
				som måste specialhanteras (den har nyckeln 0 i normalfallet).
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Adam Holmström
 #CreateDate:		140213
 #Modified by:		
 #ModifiedDate:		
 
 #Log:
	
********************************************************************/
CREATE PROCEDURE [dbo].[Support_SetCellCommentDimensionElementKey] AS
BEGIN
	UPDATE CellCommentDimension
	SET ElementKey = Reverse(SUBSTRING(Reverse(FullMemberName), 2, CHARINDEX('[', Reverse(FullMemberName)) - 2))
	WHERE ElementKey IS NULL OR ElementKey = ''
END
GO
