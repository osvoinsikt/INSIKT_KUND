SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[fact_Resultat_Planning](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlanningVersionID] [int] NOT NULL,
	[PostingDateID] [int] NOT NULL,
	[AvdelningID] [int] NOT NULL,
	[KampanjID] [int] NOT NULL,
	[ProjektID] [int] NOT NULL,
	[VarugruppID] [int] NOT NULL,
	[KontoID] [int] NOT NULL,
	[Organisation_LeafID] [int] NOT NULL,
	[PlanningAmount] [numeric](28, 8) NULL,
	[PlanningQuantity] [numeric](28, 8) NULL,
	[AuditUser] [nvarchar](255) NULL,
	[AuditTime] [datetime] NULL,
	[ExistsInWriteTable] [bit] NOT NULL,
	[IncUpdate] [bit] NOT NULL,
	[RowTypeID] [smallint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_fact_Resultat_Planning_IncUpdate] ON [dw].[fact_Resultat_Planning]
(
	[IncUpdate] ASC
)
WHERE ([IncUpdate]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_fact_Resultat_Planning_Organisation] ON [dw].[fact_Resultat_Planning]
(
	[AvdelningID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dw].[fact_Resultat_Planning] ADD  DEFAULT ((0)) FOR [ExistsInWriteTable]
GO
ALTER TABLE [dw].[fact_Resultat_Planning] ADD  DEFAULT ((0)) FOR [IncUpdate]
GO
