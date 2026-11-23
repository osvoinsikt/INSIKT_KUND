SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [insikt].[DTD_Projektanalys_Utfall]
(
	@measureUniqueName varchar(200),
	@userID int
)
as
	select distinct 
		[FCProjectID] = f.FCProjectID
		,[ProjektID] = f.ProjektID
		,[MonthID] = f.MonthID
		,[DateID] = f.DateID
		,[KontoID] = f.KontoID
	into #DTD
	from dw.fact_Projekt_Utfall_Analysis f
		inner join #DrillthroughID dtd ON
			f.KontoID = dtd.Konto_KontoID and
			f.DateID = dtd.Datum_DateID and
			f.FCProjectID = dtd.[INSIKT Projekt_FCProjectID]

	select
		[Datum] = t.DateName
		,[Transaktionstyp] = glType.DisplayName
		,[Konto] = k.Konto_DisplayName
		,[Projekt] = fcp.DisplayName
		,[Belopp] = f.Amount
		,[Antal] = f.Number
		-- Denna behöver justeras beroende på källa och vart fakturabilder hämtas från
		-- ,[Faktura] = case when f.Ver_Nr = NULL then Null  
		-- 			else 'select 1 as CompanyId, ' + cast(f.Ver_Nr as varchar(50)) + ' as InvoiceNumber'
		-- 			end
		-- ,[InvoiceLinkConfigurationID] = 5
	 from dw.fact_GeneralLedger f								
		inner join dw.dim_Time t on
			t.DateID = f.PostingDateID
		inner join #DTD dtd on
			dtd.MonthID = t.MonthID
			and dtd.ProjektID = f.ProjektID
			and dtd.KontoID = f.KontoID					
		inner join dw.dim_Konto_Projekt k on
			k.KontoID = f.KontoID				
		inner join dw.base_FCProject fcp on
			fcp.FCProjectID = dtd.FCProjectID			
		inner join dw.base_GLTransactionType glType on
			glType.GLTransactionTypeID = f.GLTransactionTypeID

GO
