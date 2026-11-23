SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[KPIIntegrationSettings](
	[KPIID] [int] NOT NULL,
	[Enabled] [bit] NOT NULL,
	[ExternalKey] [nvarchar](15) NOT NULL,
	[IsActualValueInputIntegrationEnabled] [bit] NOT NULL,
	[IsTargetValueInputIntegrationEnabled] [bit] NOT NULL,
 CONSTRAINT [PK_Scorecard_KPIIntegrationSettings] PRIMARY KEY CLUSTERED 
(
	[KPIID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Scorecard_KPIIntegrationSettings_ExternalKey] UNIQUE NONCLUSTERED 
(
	[ExternalKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [scorecard].[KPIIntegrationSettings]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPIIntegrationSettings_KPI] FOREIGN KEY([KPIID])
REFERENCES [scorecard].[KPI] ([ID])
GO
ALTER TABLE [scorecard].[KPIIntegrationSettings] CHECK CONSTRAINT [FK_Scorecard_KPIIntegrationSettings_KPI]
GO
