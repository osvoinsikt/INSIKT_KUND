SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dw].[fact_GeneralLedger](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PostingDateID] [int] NOT NULL,
	[KontoID] [int] NOT NULL,
	[GLTransactionTypeID] [int] NOT NULL,
	[VerifikationstypID] [int] NOT NULL,
	[LeverantörID] [int] NOT NULL,
	[AnläggningID] [int] NOT NULL,
	[KundID] [int] NOT NULL,
	[AnställdID] [int] NOT NULL,
	[KampanjID] [int] NOT NULL,
	[VarugruppID] [int] NOT NULL,
	[KassaID] [int] NOT NULL,
	[ProjektID] [int] NOT NULL,
	[AvdelningID] [int] NOT NULL,
	[Amount] [numeric](28, 8) NULL,
	[Number] [numeric](28, 8) NULL,
	[RowTypeID] [smallint] NOT NULL,
	[SA_SourceSystemID] [int] NOT NULL,
	[JNo] [int] NULL,
	[EntNo] [int] NULL,
	[VouNo] [int] NULL,
	[ChDt] [int] NULL,
	[ChTm] [smallint] NULL,
	[Txt] [varchar](200) NULL,
	[InvoiceDocumentID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [IX_fact_GeneralLedger_Organisation] ON [dw].[fact_GeneralLedger]
(
	[AvdelningID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
