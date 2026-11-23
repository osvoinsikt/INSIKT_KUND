SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Hämtar alla matchande FCElementProperties. En rad räknas som en match om den antingen har rätt
	bolag/budgettyp eller om den har NULL i kolumnen ifråga. Om det finns både rader med rätt värde
	och rader med NULL i kolumnen ifråga returneras endast de rader som har värde.
*/
CREATE PROCEDURE [dbo].[selAllFCPropertyValues]
	@companyID int,
	@fcTypeID int,
	@userID int,
	@dataSourceID int
AS
BEGIN
	set nocount on;

	select
		fcp.[Name] as PropertyName,
		fcep.ValueNumeric,
		fcep.ValueString,
		fcep.FCTypeID,
		fcep.CompanyID,
		fcep.UserID,
		fcep.ElementKey as ElementKey,
		fcep.AdditionalFilter,
		el.[Name] as FCElementName,
		el.DataSourceID
	into #result
	from FCElementProperty fcep
		inner join FCProperty fcp on fcp.ID = fcep.PropertyID
		inner join FCElement el on el.ID = fcep.FCElementID
	where
		(fcep.FCTypeID is null or fcep.FCTypeID = @fcTypeID)
		and (fcep.CompanyID is null or fcep.CompanyID = @companyID)
		and (fcep.UserID is null or fcep.UserID = @userID)
		and (el.Name = 'Inställningar' or el.DataSourceID = @dataSourceID)

	-- Ta bort rader utan bolag om det finns rader med.
	delete r1
	from #result r1
		inner join #result r2 on r2.PropertyName = r1.PropertyName and r2.FCElementName = r1.FCElementName and r2.ElementKey = r1.ElementKey and r2.CompanyID is not null and r1.CompanyID is null

	-- Ta bort rader utan budgettyp om det finns rader med.
	delete r1
	from #result r1
		inner join #result r2 on r2.PropertyName = r1.PropertyName and r2.FCElementName = r1.FCElementName and r2.ElementKey = r1.ElementKey and r2.FCTypeID is not null and r1.FCTypeID is null

	select
		FCElementName,
		PropertyName,
		ElementKey,
		ValueNumeric,
		ValueString,
		AdditionalFilter,
		UserID
	from #result
END


GO
