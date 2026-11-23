SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Selects a specific property based on the
 #			FCElementName and the PropertyName
 #Used By:		-
 #InParam:		-
 #ResultSet:		
 #
 #Returns:		
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		041002
 #Modified by:		Jonas Markström
 #ModifiedDate:		201125
 
 #Log:		090402	ANHO	Lagt till UserID
			201125  JOMA	La till argument om FCElement.DataSourceID

********************************************************************/
CREATE           Procedure [dbo].[selFCPropertiesByElementAndPropertyName]
		@vsFCElementName varchar(50)
		,@vsFCPropertyName varchar(50)
		,@DataSourceID int

AS

-- selFCPropertiesByElementAndPropertyName 'Kontoplan', 'Budgeteras'

select 	fcep.[ID]
	,fcep.[ElementKey]
	,fcep.[ValueNumeric]
	,fcep.[ValueString]
	,fcp.[Name] as PropertyName
	,fcp.[Description] as PropertyDescription
	,fcp.[Datatype] as PropertyDatatype
	,fcep.[FCTypeID]
	,fcep.[UserID]

from 		[FCElementProperty] fcep 
inner join 	FCProperty fcp on fcep.PropertyID = fcp.[ID]
inner join	FCElement fce on fcep.FCElementID = fce.[ID]

where 	fce.[Name] = @vsFCElementName
AND	fcp.[Name] = @vsFCPropertyName
AND (fce.[DataSourceID] IS NULL OR @DataSourceID IS NULL OR fce.[DataSourceID] = @DataSourceID)
GO
