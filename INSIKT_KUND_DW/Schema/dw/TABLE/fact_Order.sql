SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dw].[fact_Order](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TransactionDateID] [int] NOT NULL,
	[OrderDateID] [int] NOT NULL,
	[LagerID] [int] NOT NULL,
	[LeverantörID] [int] NOT NULL,
	[TransaktionstypID] [int] NOT NULL,
	[AnläggningID] [int] NOT NULL,
	[KundID] [int] NOT NULL,
	[FakturerasKundID] [int] NOT NULL,
	[SäljInköpAnställdID] [int] NOT NULL,
	[AnställdID] [int] NOT NULL,
	[KampanjID] [int] NOT NULL,
	[VarugruppID] [int] NOT NULL,
	[KassaID] [int] NOT NULL,
	[ProjektID] [int] NOT NULL,
	[AvdelningID] [int] NOT NULL,
	[ProduktID] [int] NOT NULL,
	[OrderBelopp] [decimal](28, 8) NULL,
	[OrderAntal] [decimal](28, 8) NULL,
	[OrderRabatt] [decimal](28, 8) NULL,
	[OrderKostnad] [decimal](28, 8) NULL,
	[OrderVolym] [decimal](28, 8) NULL,
	[OrderEmballagevikt] [decimal](28, 8) NULL,
	[OrderNettovikt] [decimal](28, 8) NULL,
	[ÖppenOrderBelopp] [decimal](28, 8) NULL,
	[ÖppenOrderAntal] [decimal](28, 8) NULL,
	[ÖppenOrderRabatt] [decimal](28, 8) NULL,
	[ÖppenOrderKostnad] [decimal](28, 8) NULL,
	[ÖppenOrderVolym] [decimal](28, 8) NULL,
	[ÖppenOrderEmballagevikt] [decimal](28, 8) NULL,
	[ÖppenOrderNettovikt] [decimal](28, 8) NULL,
	[InvoiceNumber] [nvarchar](50) NULL,
	[JNo] [int] NOT NULL,
	[OrdNo] [int] NOT NULL,
	[OrdLnNo] [int] NOT NULL,
	[ChDt] [int] NOT NULL,
	[ChTm] [smallint] NOT NULL,
	[Txt] [varchar](60) NULL,
	[RowTypeID] [smallint] NOT NULL,
	[SA_SourceSystemID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
