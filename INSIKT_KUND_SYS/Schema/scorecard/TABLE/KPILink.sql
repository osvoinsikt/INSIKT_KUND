SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[KPILink](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KPIID] [int] NOT NULL,
	[ReportID] [int] NULL,
	[FCTypeID] [int] NULL,
	[PrognosisTabTypeID] [int] NULL,
	[SyncOrganisation] [bit] NOT NULL,
 CONSTRAINT [PK_Scorecard_KPILink] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [scorecard].[KPILink]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPILink_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [scorecard].[KPILink] CHECK CONSTRAINT [FK_Scorecard_KPILink_FCType]
GO
ALTER TABLE [scorecard].[KPILink]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPILink_KPIID] FOREIGN KEY([KPIID])
REFERENCES [scorecard].[KPI] ([ID])
GO
ALTER TABLE [scorecard].[KPILink] CHECK CONSTRAINT [FK_Scorecard_KPILink_KPIID]
GO
ALTER TABLE [scorecard].[KPILink]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPILink_PrognosisTabTypeID] FOREIGN KEY([PrognosisTabTypeID])
REFERENCES [scorecard].[KPILinkPrognosisTabType] ([ID])
GO
ALTER TABLE [scorecard].[KPILink] CHECK CONSTRAINT [FK_Scorecard_KPILink_PrognosisTabTypeID]
GO
ALTER TABLE [scorecard].[KPILink]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPILink_Report] FOREIGN KEY([ReportID])
REFERENCES [dbo].[Report] ([ID])
GO
ALTER TABLE [scorecard].[KPILink] CHECK CONSTRAINT [FK_Scorecard_KPILink_Report]
GO
