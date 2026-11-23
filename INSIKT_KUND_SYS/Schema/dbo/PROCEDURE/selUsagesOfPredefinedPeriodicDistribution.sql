SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:			Linus Nilsson
-- Create date:		2015-07-01
-- Description:		Hittar alla celler som använder en viss fördefinierad periodiseringskurva. I vanlig
--					budget och projekt (ej projektkalkyl) läses celler endast upp för öppna versioner.
--					I projektkalkyl läses alla celler upp oavsett version, eftersom skrivbarheten inte
--					avgörs av versionen.
--
-- Modified by:		EMAH
-- Modified date:	2017-02-14
-- Log:				Updated after FCType configuration refactor
--
-- Modified by:		JOMA
-- Modified date:	2018-11-05
-- Log:				Updated the matching of dimension connections to the new way (multiple row dimensions).
-- =============================================
CREATE PROCEDURE [dbo].[selUsagesOfPredefinedPeriodicDistribution]
	@predefinedDistributionID int
AS
BEGIN
	select
		epd.ID, epd.FCTypeID, epd.CompanyID
	from
		FCElementPeriodicDistribution epd

		inner join FCElementProperty ep_org
			on ep_org.PropertyID = 8
				and ep_org.FCTypeID = epd.FCTypeID
				and ep_org.CompanyID = epd.CompanyID
		inner join FCElementPeriodicDistributionDimension dim_org
			on dim_org.PeriodicDistributionID = epd.ID
				and dim_org.DimensionName = ep_org.ValueString

		inner join FCElementProperty ep_version
			on ep_version.PropertyID = 9
				and ep_version.FCTypeID = epd.FCTypeID
				and ep_version.CompanyID = epd.CompanyID
		inner join FCElementPeriodicDistributionDimension dim_version
			on dim_version.PeriodicDistributionID = epd.ID
				and dim_version.DimensionName = ep_version.ValueString

		inner join FCVersion v on cast(v.ID as nvarchar) = dim_version.ElementKey

		-- Bara aktiva budgettyper.
		inner join FCType fct
			on fct.ID = epd.FCTypeID
				and fct.IsActive = 1

		left join FCProjectCalcProcess pcp
			on pcp.FCVersionID = v.ID
				and cast(pcp.FCProjectID as nvarchar) = dim_org.ElementKey

	where epd.PredefinedID = @predefinedDistributionID
		-- Versionen ska vara skrivbar om det inte är projektkalkyl. I projektkalkyl kan
		-- skrivbarheten kontrolleras per process efter uppläsning.
		and (pcp.ID is null or v.IsBudget = 1)


	select
		epd.ID,
		pdd.DimensionName,
		pdd.ElementKey
	from
		FCElementPeriodicDistribution epd

		inner join FCElementPeriodicDistributionDimension pdd
			on epd.PredefinedID = @predefinedDistributionID
				and pdd.PeriodicDistributionID = epd.ID

END
GO
