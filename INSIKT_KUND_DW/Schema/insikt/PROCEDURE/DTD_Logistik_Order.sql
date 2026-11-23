SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [insikt].[DTD_Logistik_Order]
(
	@measureUniqueName varchar(200),
	@userID int
)
as
	select ID
	into #DTD
	from [dw].[fact_Order_WithOrg] f
		inner join #DrillthroughID dtd ON
					f.[LagerID] = dtd.[Lager_LagerID]
					and f.[LeverantörID] = dtd.[Leverantör_LeverantörID]
					and f.[TransaktionstypID] = dtd.[Transaktionstyp_TransaktionstypID]
					and f.[AnläggningID] = dtd.[Anläggning_AnläggningID]
					and f.[KundID] = dtd.[Kund_KundID]
					and f.[FakturerasKundID] = dtd.[Faktureras_Kund_KundID]
					and f.[SäljInköpAnställdID] = dtd.[Sälj_Inköp_Anställd_AnställdID]
					and f.[AnställdID] = dtd.[Anställd_AnställdID]
					and f.[KampanjID] = dtd.[Kampanj_KampanjID]
					and f.[VarugruppID] = dtd.[Varugrupp_VarugruppID]
					and f.[KassaID] = dtd.[Kassa_KassaID]
					and f.[ProjektID] = dtd.[Projekt_ProjektID]
					and f.[AvdelningID] = dtd.[Avdelning_AvdelningID]
					and f.[ProduktID] = dtd.[Produkt_ProduktID]
					and f.[TransactionDateID] = dtd.[Transaktionsdatum_DateID]
					and f.[OrderDateID] = dtd.[Orderdatum_DateID]
		

	select
			[Transaktionsdatum] = case when [Transaktionsdatum].[DateID] = 0 then '' else [Transaktionsdatum].DateName end
			,[Orderdatum] = case when [Orderdatum].[DateID] = 0 then '' else [Orderdatum].DateName end
			
		,[Lager] = case when [Lager].[LagerID] < 0 then '' else 
		 [Lager].DisplayName end
		
		,[Leverantör] = case when [Leverantör].[LeverantörID] < 0 then '' else 
		 [Leverantör].DisplayName end
		
		,[Transaktionstyp] = case when [Transaktionstyp].[TransaktionstypID] < 0 then '' else 
		 [Transaktionstyp].DisplayName end
		
		,[Anläggning] = case when [Anläggning].[AnläggningID] < 0 then '' else 
		 [Anläggning].DisplayName end
		
		,[Kund] = case when [Kund].[KundID] < 0 then '' else 
		 [Kund].DisplayName end
		
		,[Faktureras_Kund] = case when [Faktureras_Kund].[KundID] < 0 then '' else 
		 [Faktureras_Kund].DisplayName end
		
		,[Sälj_Inköp_Anställd] = case when [Sälj_Inköp_Anställd].[AnställdID] < 0 then '' else 
		 [Sälj_Inköp_Anställd].DisplayName end
		
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
		
		,[Produkt] = case when [Produkt].[ProduktID] < 0 then '' else 
		 [Produkt].DisplayName end
			
		,[Belopp] = f.[OrderBelopp]
		
		,[Antal] = f.[OrderAntal]
		
		,[Rabatt] = f.[OrderRabatt]
		
		,[Kostnad] = f.[OrderKostnad]
		
		,[Volym] = f.[OrderVolym]
		
		,[Emballagevikt] = f.[OrderEmballagevikt]
		
		,[Nettovikt] = f.[OrderNettovikt]
		
		,[Öppet belopp] = f.[ÖppenOrderBelopp]
		
		,[Öppet antal] = f.[ÖppenOrderAntal]
		
		,[Öppet rabatt] = f.[ÖppenOrderRabatt]
		
		,[Öppet kostnad] = f.[ÖppenOrderKostnad]
		
		,[Öppet volym] = f.[ÖppenOrderVolym]
		
		,[Öppet emballagevikt] = f.[ÖppenOrderEmballagevikt]
		
		,[Öppet nettovikt] = f.[ÖppenOrderNettovikt]
		
		,[InvoiceNumber] = f.[InvoiceNumber]
		
		,[JNo] = f.[JNo]
		
		,[OrdNo] = f.[OrdNo]
		
		,[OrdLnNo] = f.[OrdLnNo]
		
		,[Text] = f.[Txt]
			from [dw].[fact_Order_WithOrg] f
		inner join #DTD dtd on
			f.ID = dtd.ID
							
		inner join [dw].[base_Lager] [Lager] on
			[Lager].[LagerID] = f.[LagerID]
							
		inner join [dw].[base_Leverantör] [Leverantör] on
			[Leverantör].[LeverantörID] = f.[LeverantörID]
							
		inner join [dw].[base_Transaktionstyp] [Transaktionstyp] on
			[Transaktionstyp].[TransaktionstypID] = f.[TransaktionstypID]
							
		inner join [dw].[base_Anläggning] [Anläggning] on
			[Anläggning].[AnläggningID] = f.[AnläggningID]
							
		inner join [dw].[base_Kund] [Kund] on
			[Kund].[KundID] = f.[KundID]
							
		inner join [dw].[base_Kund] [Faktureras_Kund] on
			[Faktureras_Kund].[KundID] = f.[FakturerasKundID]
							
		inner join [dw].[base_Anställd] [Sälj_Inköp_Anställd] on
			[Sälj_Inköp_Anställd].[AnställdID] = f.[SäljInköpAnställdID]
							
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
							
		inner join [dw].[base_Produkt] [Produkt] on
			[Produkt].[ProduktID] = f.[ProduktID]
								
		inner join [dw].[dim_Time] Transaktionsdatum on
			[Transaktionsdatum].[DateID] = f.[TransactionDateID]
							
		inner join [dw].[dim_Time] Orderdatum on
			[Orderdatum].[DateID] = f.[OrderDateID]
			
GO
