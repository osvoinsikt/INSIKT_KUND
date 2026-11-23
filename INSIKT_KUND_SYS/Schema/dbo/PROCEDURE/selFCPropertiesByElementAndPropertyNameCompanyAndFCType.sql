SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Selects a specific property based on the
 #			FCElementName and the PropertyName and Company and FCType
 #Used By:		-
 #InParam:		-
 #ResultSet:		
 #
 #Returns:		
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		060628
 #Modified by:		Jonas Markström
 #ModifiedDate:		201125
 
 #Log:	061024	DH	La till stöd för att ta default-värden. Ändrade till att gå på CompanyID i instanstabellen istället för element-tabellen.
		090402	ANHO	Lagt till UserID
		201125  JOMA	Bytte ut FCElement.Cube till FCElement.DataSourceID

********************************************************************/
CREATE Procedure [dbo].[selFCPropertiesByElementAndPropertyNameCompanyAndFCType]
		@vsFCElementName varchar(50)
		,@vsFCPropertyName varchar(50)
		,@nCompanyID int
		,@nFCTypeID int
		,@DataSourceID int
	
AS

-- selFCPropertiesByElementAndPropertyNameCompanyAndFCType 'Kontoplan', 'Budgeteras' ,4,0
declare @nrOfRows int

select 	fcep.[ID]
	,fcep.[ElementKey]
	,fcep.[ValueNumeric]
	,fcep.[ValueString]
	,fcp.[Name] as PropertyName
	,fcp.[Description] as PropertyDescription
	,fcp.[Datatype] as PropertyDatatype
	,fcep.FCTypeID
	,fcep.CompanyID as CompanyID
	,fcep.[UserID]
	,fcep.AdditionalFilter


into #results
from 		[FCElementProperty] fcep 
inner join 	FCProperty fcp on fcep.PropertyID = fcp.[ID]
inner join	FCElement fce on fcep.FCElementID = fce.[ID]

where 	fce.[Name] = @vsFCElementName
AND (fce.[DataSourceID] IS NULL OR @DataSourceID IS NULL OR fce.[DataSourceID] = @DataSourceID)
AND	fcp.[Name] = @vsFCPropertyName

select @nrOfRows = count(*) from #results

if @nrOfRows = 0
	select * from #results
else
begin
	select  @nrOfRows = count(*) from #results Where CompanyID = @nCompanyID AND[FCTypeID] = @nFCTypeID

	if @nrOfRows > 0
		select * from #results Where CompanyID = @nCompanyID AND [FCTypeID] = @nFCTypeID
	else
	begin
		select @nrOfRows = count(*) from #results Where CompanyID = @nCompanyID AND [FCTypeID] is null
		if @nrOfRows > 0
			select * from #results Where CompanyID = @nCompanyID AND [FCTypeID] is null
		else
		begin
			select @nrOfRows = count(*) from #results Where CompanyID is null AND [FCTypeID] = @nFCTypeID
			if @nrOfRows > 0
				select * from #results Where CompanyID is null AND [FCTypeID] = @nFCTypeID
			else
				select * from #results Where CompanyID is null and FCTypeID is null
		end
	end
end
GO
