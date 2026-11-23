SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Selects a specific property based on the
 #			FCElementName and the PropertyName and Company
 #Used By:		-
 #InParam:		-
 #ResultSet:		
 #
 #Returns:		
 #Owner:		DBO
 #Creator:		Andreas Åström
 #CreateDate:		051020
 #Modified by:		Jonas Markström
 #ModifiedDate:		201125
 
 #Log:	061024	DH	La till stöd för att ta default-värden. Ändrade till att gå på CompanyID i instanstabellen istället för element-tabellen.
		090402	ANHO	Lagt till UserID
		201125  JOMA	Bytte ut FCElement.Cube till FCElement.DataSourceID

********************************************************************/
CREATE Procedure [dbo].[selFCPropertiesByElementAndPropertyNameAndCompany]
		@vsFCElementName varchar(50)
		,@vsFCPropertyName varchar(50)
		,@nCompanyID int
		,@DataSourceID int
AS

-- selFCPropertiesByElementAndPropertyName 'Kontoplan', 'Budgeteras'
declare @nrOfRows int


select 	fcep.[ID]
	,fcep.[ElementKey]
	,fcep.[ValueNumeric]
	,fcep.[ValueString]
	,fcp.[Name] as PropertyName
	,fcp.[Description] as PropertyDescription
	,fcp.[Datatype] as PropertyDatatype
	,fcep.FCTypeID
	,fcep.CompanyID
	,fcep.[UserID]
	,fcep.AdditionalFilter

into #results
from 		[FCElementProperty] fcep 
inner join 	FCProperty fcp on fcep.PropertyID = fcp.[ID]
inner join	FCElement fce on fcep.FCElementID = fce.[ID]

where 	fce.[Name] = @vsFCElementName
AND (fce.[DataSourceID] IS NULL OR @DataSourceID IS NULL OR fce.[DataSourceID] = @DataSourceID)
AND	fcp.[Name] = @vsFCPropertyName


--Ta fram hur många rader vi fick
select @nrOfRows = count(*) from #results


if @nrOfRows = 0
	select * from #results
else
begin
	select  @nrOfRows = count(*) from #results Where CompanyID = @nCompanyID
	
	if @nrOfRows > 0
		select * from #results Where CompanyID = @nCompanyID
	else
		select * from #results where CompanyID is null
end
GO
