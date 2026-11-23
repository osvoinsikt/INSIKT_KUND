SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dw].[fact_Resultat] asselect	[ID] = f.[ID]
	,[PostingDateID] = f.[PostingDateID]
	,[KontoID] = f.[KontoID]
	,[GLTransactionTypeID] = f.[GLTransactionTypeID]
	,[VerifikationstypID] = f.[VerifikationstypID]
	,[LeverantörID] = f.[LeverantörID]
	,[AnläggningID] = f.[AnläggningID]
	,[KundID] = f.[KundID]
	,[AnställdID] = f.[AnställdID]
	,[KampanjID] = f.[KampanjID]
	,[VarugruppID] = f.[VarugruppID]
	,[KassaID] = f.[KassaID]
	,[ProjektID] = f.[ProjektID]
	,[AvdelningID] = f.[AvdelningID]
	,[Amount] = -f.Amount
	,[Number] = f.[Number]
	,[RowTypeID] = f.[RowTypeID]
	,[SA_SourceSystemID] = f.[SA_SourceSystemID]
	,[JNo] = f.[JNo]
	,[EntNo] = f.[EntNo]
	,[VouNo] = f.[VouNo]
	,[ChDt] = f.[ChDt]
	,[ChTm] = f.[ChTm]
	,[Txt] = f.[Txt]
	,[InvoiceDocumentID] = f.[InvoiceDocumentID]
		  ,Organisation_LeafID = dimOrg.Organisation_LeafIDfrom  [dw].[fact_GeneralLedger] f	inner join [dw].[dim_Resultatkonto] dim on	  dim.KontoID = f.KontoID 	inner join dw.dim_Organisation dimOrg on	 	   dimOrg.[AvdelningID] = f.[AvdelningID] 	
GO
