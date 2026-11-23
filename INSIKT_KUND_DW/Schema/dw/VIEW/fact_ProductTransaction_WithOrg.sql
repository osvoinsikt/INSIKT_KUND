SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dw].[fact_ProductTransaction_WithOrg] as
select
	[ID] = f.[ID]
	,[TransactionDateID] = f.[TransactionDateID]
	,[InvoiceDateID] = f.[InvoiceDateID]
 
  ,[LagerID] = f.[LagerID]
 
  ,[LeverantörID] = f.[LeverantörID]
 
  ,[TransaktionstypID] = f.[TransaktionstypID]
 
  ,[AnläggningID] = f.[AnläggningID]
 
  ,[KundID] = f.[KundID]
 
  ,[FakturerasKundID] = f.[FakturerasKundID]
 
  ,[SäljInköpAnställdID] = f.[SäljInköpAnställdID]
 
  ,[AnställdID] = f.[AnställdID]
 
  ,[KampanjID] = f.[KampanjID]
 
  ,[VarugruppID] = f.[VarugruppID]
 
  ,[KassaID] = f.[KassaID]
 
  ,[ProjektID] = f.[ProjektID]
 
  ,[AvdelningID] = f.[AvdelningID]
 
  ,[ProduktID] = f.[ProduktID]
	,[FakturaBelopp] = f.[FakturaBelopp]
	,[FakturaAntal] = f.[FakturaAntal]
	,[FakturaRabatt] = f.[FakturaRabatt]
	,[FakturaKostnad] = f.[FakturaKostnad]
	,[FakturaVolym] = f.[FakturaVolym]
	,[FakturaEmballagevikt] = f.[FakturaEmballagevikt]
	,[FakturaNettovikt] = f.[FakturaNettovikt]
	,[InvoiceNumber] = f.[InvoiceNumber]
	,[JNo] = f.[JNo]
	,[TrNo] = f.[TrNo]
	,[OrdNo] = f.[OrdNo]
	,[OrdLnNo] = f.[OrdLnNo]
	,[ChDt] = f.[ChDt]
	,[ChTm] = f.[ChTm]
	,[Txt] = f.[Txt]
	,[RowTypeID] = f.[RowTypeID]
	,[SA_SourceSystemID] = f.[SA_SourceSystemID]
	,Organisation_LeafID = dimOrg.Organisation_LeafID
from
	[dw].[fact_ProductTransaction] f
		inner join dw.dim_Organisation dimOrg on
		 
		   dimOrg.[AvdelningID] = f.[AvdelningID] 
		
GO
