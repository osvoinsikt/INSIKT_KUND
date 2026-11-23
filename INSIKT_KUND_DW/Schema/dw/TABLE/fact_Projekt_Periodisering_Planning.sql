SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[fact_Projekt_Periodisering_Planning](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectID] [int] NOT NULL,
	[FCVersionID] [int] NOT NULL,
	[MonthID] [int] NOT NULL,
	[KontoID] [int] NOT NULL,
	[PeriodiseratBelopp] [decimal](28, 8) NULL,
	[FgPeriodiseratBelopp] [decimal](28, 8) NULL,
	[AuditUser] [nvarchar](255) NULL,
	[AuditTime] [datetime] NULL,
	[ExistsInWriteTable] [bit] NOT NULL,
	[IncUpdate] [bit] NOT NULL,
	[RowTypeID] [smallint] NOT NULL,
 CONSTRAINT [PK__fact_Pro__2214EC27CBD40B17] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_fact_Projekt_Periodisering_Planning_IncUpdate] ON [dw].[fact_Projekt_Periodisering_Planning]
(
	[IncUpdate] ASC
)
WHERE ([IncUpdate]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dw].[fact_Projekt_Periodisering_Planning] ADD  CONSTRAINT [DF__fact_Proj__Exist__6301FCD8]  DEFAULT ((0)) FOR [ExistsInWriteTable]
GO
ALTER TABLE [dw].[fact_Projekt_Periodisering_Planning] ADD  CONSTRAINT [DF__fact_Proj__IncUp__65312111]  DEFAULT ((0)) FOR [IncUpdate]
GO
