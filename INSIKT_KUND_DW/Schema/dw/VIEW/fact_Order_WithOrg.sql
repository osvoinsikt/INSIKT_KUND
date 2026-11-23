SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dw].[fact_Order_WithOrg] as
select
	[ID] = f.[ID]
	,[TransactionDateID] = f.[TransactionDateID]
	,[OrderDateID] = f.[OrderDateID]
 
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
	,[OrderBelopp] = f.[OrderBelopp]
	,[OrderAntal] = f.[OrderAntal]
	,[OrderRabatt] = f.[OrderRabatt]
	,[OrderKostnad] = f.[OrderKostnad]
	,[OrderVolym] = f.[OrderVolym]
	,[OrderEmballagevikt] = f.[OrderEmballagevikt]
	,[OrderNettovikt] = f.[OrderNettovikt]
	,[ÖppenOrderBelopp] = f.[ÖppenOrderBelopp]
	,[ÖppenOrderAntal] = f.[ÖppenOrderAntal]
	,[ÖppenOrderRabatt] = f.[ÖppenOrderRabatt]
	,[ÖppenOrderKostnad] = f.[ÖppenOrderKostnad]
	,[ÖppenOrderVolym] = f.[ÖppenOrderVolym]
	,[ÖppenOrderEmballagevikt] = f.[ÖppenOrderEmballagevikt]
	,[ÖppenOrderNettovikt] = f.[ÖppenOrderNettovikt]
	,[InvoiceNumber] = f.[InvoiceNumber]
	,[JNo] = f.[JNo]
	,[OrdNo] = f.[OrdNo]
	,[OrdLnNo] = f.[OrdLnNo]
	,[ChDt] = f.[ChDt]
	,[ChTm] = f.[ChTm]
	,[Txt] = f.[Txt]
	,[RowTypeID] = f.[RowTypeID]
	,[SA_SourceSystemID] = f.[SA_SourceSystemID]
	,Organisation_LeafID = dimOrg.Organisation_LeafID
from
	[dw].[fact_Order] f
		inner join dw.dim_Organisation dimOrg on
		 
		   dimOrg.[AvdelningID] = f.[AvdelningID] 
		
GO
