SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*******************************************************************
 #Desc: 		Selects available PredefinedValues for given property
 #Used By:		Project Prognosis Module
 #InParam:		iProjectID - ID of the project
 #ResultSet:		All information on the specified project
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Anders Holm
 #CreateDate:		111129
 #Modified by:		
 #ModifiedDate:		
 
 #Log:			
		111129	ANHO	-Created
	

********************************************************************/
CREATE             Procedure [dbo].[selFCProjectPropertyPredefinedValues]
		@FCProjectPropertyID int

AS

-- [selFCProjectPropertyPredefinedValues] 15

SELECT pppv.* FROM FCProjectPropertyPredefinedValue pppv
inner join FCProjectProperty pp on pp.ID = pppv.FCProjectPropertyID and pp.ID = @FCProjectPropertyID
order by pppv.SortOrder
GO
