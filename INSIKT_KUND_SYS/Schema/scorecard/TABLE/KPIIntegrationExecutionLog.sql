SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[KPIIntegrationExecutionLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionID] [int] NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
	[EventDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Scorecard_KPIIntegrationExecutionLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [scorecard].[KPIIntegrationExecutionLog]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPIIntegrationExecutionLog_ExecutionID] FOREIGN KEY([ExecutionID])
REFERENCES [scorecard].[KPIIntegrationExecution] ([ID])
GO
ALTER TABLE [scorecard].[KPIIntegrationExecutionLog] CHECK CONSTRAINT [FK_Scorecard_KPIIntegrationExecutionLog_ExecutionID]
GO
