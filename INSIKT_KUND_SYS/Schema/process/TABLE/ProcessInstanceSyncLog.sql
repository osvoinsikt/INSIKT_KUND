SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [process].[ProcessInstanceSyncLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessInstanceID] [int] NOT NULL,
	[ProcessTemplateRevisionID] [int] NOT NULL,
	[ProcessInstanceActivityID] [int] NULL,
	[ProcessInstanceActivityStepID] [int] NULL,
	[Log] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_ProcessInstanceSyncLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [process].[ProcessInstanceSyncLog]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstanceSyncLog_ProcessInstance] FOREIGN KEY([ProcessInstanceID])
REFERENCES [process].[ProcessInstance] ([ID])
GO
ALTER TABLE [process].[ProcessInstanceSyncLog] CHECK CONSTRAINT [FK_ProcessInstanceSyncLog_ProcessInstance]
GO
ALTER TABLE [process].[ProcessInstanceSyncLog]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstanceSyncLog_ProcessInstanceActivity] FOREIGN KEY([ProcessInstanceActivityID])
REFERENCES [process].[ProcessInstanceActivity] ([ID])
GO
ALTER TABLE [process].[ProcessInstanceSyncLog] CHECK CONSTRAINT [FK_ProcessInstanceSyncLog_ProcessInstanceActivity]
GO
ALTER TABLE [process].[ProcessInstanceSyncLog]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstanceSyncLog_ProcessInstanceActivityStep] FOREIGN KEY([ProcessInstanceActivityStepID])
REFERENCES [process].[ProcessInstanceActivityStep] ([ID])
GO
ALTER TABLE [process].[ProcessInstanceSyncLog] CHECK CONSTRAINT [FK_ProcessInstanceSyncLog_ProcessInstanceActivityStep]
GO
ALTER TABLE [process].[ProcessInstanceSyncLog]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstanceSyncLog_ProcessTemplateRevision] FOREIGN KEY([ProcessTemplateRevisionID])
REFERENCES [process].[ProcessTemplateRevision] ([ID])
GO
ALTER TABLE [process].[ProcessInstanceSyncLog] CHECK CONSTRAINT [FK_ProcessInstanceSyncLog_ProcessTemplateRevision]
GO
