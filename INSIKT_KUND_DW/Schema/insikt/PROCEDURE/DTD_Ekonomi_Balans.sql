SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [insikt].[DTD_Ekonomi_Balans]
(
	@measureUniqueName varchar(200),
	@userID int
)
as
	select ID
	into #DTD
	from [dw].[fact_Balans] f
		inner join #DrillthroughID dtd ON
					f.[KontoID] = dtd.[Balanskonto_KontoID]
					and f.[GLTransactionTypeID] = dtd.[Transaktionstyp_GLTransactionTypeID]
					and f.[VerifikationstypID] = dtd.[Verifikationstyp_VerifikationstypID]
					and f.[LeverantörID] = dtd.[Leverantör_LeverantörID]
					and f.[AnläggningID] = dtd.[Anläggning_AnläggningID]
					and f.[KundID] = dtd.[Kund_KundID]
					and f.[AnställdID] = dtd.[Anställd_AnställdID]
					and f.[KampanjID] = dtd.[Kampanj_KampanjID]
					and f.[VarugruppID] = dtd.[Varugrupp_VarugruppID]
					and f.[KassaID] = dtd.[Kassa_KassaID]
					and f.[ProjektID] = dtd.[Projekt_ProjektID]
					and f.[AvdelningID] = dtd.[Avdelning_AvdelningID]
					and f.[PostingDateID] = dtd.[Datum_DateID]
					and f.[Organisation_LeafID] = dtd.[Organisation_Organisation_LeafID]
		

	select
			[Datum] = case when [Datum].[DateID] = 0 then '' else [Datum].DateName end
			
		,[Konto] = case when [Konto].[KontoID] < 0 then '' else 
		 [Konto].DisplayName end
		
		,[Transaktionstyp] = case when [Transaktionstyp].[GLTransactionTypeID] < 0 then '' else 
		 [Transaktionstyp].DisplayName end
		
		,[Verifikationstyp] = case when [Verifikationstyp].[VerifikationstypID] < 0 then '' else 
		 [Verifikationstyp].DisplayName end
		
		,[Leverantör] = case when [Leverantör].[LeverantörID] < 0 then '' else 
		 [Leverantör].DisplayName end
		
		,[Anläggning] = case when [Anläggning].[AnläggningID] < 0 then '' else 
		 [Anläggning].DisplayName end
		
		,[Kund] = case when [Kund].[KundID] < 0 then '' else 
		 [Kund].DisplayName end
		
		,[Anställd] = case when [Anställd].[AnställdID] < 0 then '' else 
		 [Anställd].DisplayName end
		
		,[Kampanj] = case when [Kampanj].[KampanjID] < 0 then '' else 
		 [Kampanj].DisplayName end
		
		,[Varugrupp] = case when [Varugrupp].[VarugruppID] < 0 then '' else 
		 [Varugrupp].DisplayName end
		
		,[Kassa] = case when [Kassa].[KassaID] < 0 then '' else 
		 [Kassa].DisplayName end
		
		,[Projekt] = case when [Projekt].[ProjektID] < 0 then '' else 
		 [Projekt].DisplayName end
		
		,[Avdelning] = case when [Avdelning].[AvdelningID] < 0 then '' else 
		 [Avdelning].DisplayName end
			
		,[Belopp] = f.[Amount]
		
		,[Antal] = f.[Number]
		
		,[JNo] = f.[JNo]
		
		,[EntNo] = f.[EntNo]
		
		,[Vernr] = f.[VouNo]
		
		,[Text] = f.[Txt]
								
		,Faktura = [invLink].[InvoiceLinkUrl]
		,InvoiceLinkConfigurationId = [invLink].[InvoiceLinkConfigurationID]
		from [dw].[fact_Balans] f
		inner join #DTD dtd on
			f.ID = dtd.ID
							
		inner join [dw].[base_Konto] [Konto] on
			[Konto].[KontoID] = f.[KontoID]
							
		inner join [dw].[base_GLTransactionType] [Transaktionstyp] on
			[Transaktionstyp].[GLTransactionTypeID] = f.[GLTransactionTypeID]
							
		inner join [dw].[base_Verifikationstyp] [Verifikationstyp] on
			[Verifikationstyp].[VerifikationstypID] = f.[VerifikationstypID]
							
		inner join [dw].[base_Leverantör] [Leverantör] on
			[Leverantör].[LeverantörID] = f.[LeverantörID]
							
		inner join [dw].[base_Anläggning] [Anläggning] on
			[Anläggning].[AnläggningID] = f.[AnläggningID]
							
		inner join [dw].[base_Kund] [Kund] on
			[Kund].[KundID] = f.[KundID]
							
		inner join [dw].[base_Anställd] [Anställd] on
			[Anställd].[AnställdID] = f.[AnställdID]
							
		inner join [dw].[base_Kampanj] [Kampanj] on
			[Kampanj].[KampanjID] = f.[KampanjID]
							
		inner join [dw].[base_Varugrupp] [Varugrupp] on
			[Varugrupp].[VarugruppID] = f.[VarugruppID]
							
		inner join [dw].[base_Kassa] [Kassa] on
			[Kassa].[KassaID] = f.[KassaID]
							
		inner join [dw].[base_Projekt] [Projekt] on
			[Projekt].[ProjektID] = f.[ProjektID]
							
		inner join [dw].[base_Avdelning] [Avdelning] on
			[Avdelning].[AvdelningID] = f.[AvdelningID]
								
		inner join [dw].[dim_Time] Datum on
			[Datum].[DateID] = f.[PostingDateID]
								
		left join [dw].[fact_InvoiceLink] invLink on
					[invLink].[SA_SourceSystemID] = [f].[SA_SourceSystemID]
					and [invLink].[InvoiceDocumentID] = [f].[InvoiceDocumentID]
										
		where f.RowTypeID <> 11
	
GO
