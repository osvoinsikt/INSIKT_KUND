SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[KPIIntegrationExecution](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KPIID] [int] NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NULL,
	[IsInputIntegration] [bit] NOT NULL,
	[InitiatedViaWriteback] [bit] NOT NULL,
	[ExecutionStatus] [int] NOT NULL,
 CONSTRAINT [PK_Scorecard_KPIIntegrationExecution] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [scorecard].[KPIIntegrationExecution]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPIIntegrationExecution_KPI] FOREIGN KEY([KPIID])
REFERENCES [scorecard].[KPI] ([ID])
GO
ALTER TABLE [scorecard].[KPIIntegrationExecution] CHECK CONSTRAINT [FK_Scorecard_KPIIntegrationExecution_KPI]
GO
ALTER TABLE [scorecard].[KPIIntegrationExecution]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPIIntegrationExecution_Status] FOREIGN KEY([ExecutionStatus])
REFERENCES [scorecard].[KPIIntegrationExecutionStatus] ([ID])
GO
ALTER TABLE [scorecard].[KPIIntegrationExecution] CHECK CONSTRAINT [FK_Scorecard_KPIIntegrationExecution_Status]
GO
