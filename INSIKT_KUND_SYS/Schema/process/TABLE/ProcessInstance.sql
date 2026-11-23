SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [process].[ProcessInstance](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OriginalProcessTemplateRevisionID] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CurrentProcessTemplateRevisionID] [int] NOT NULL,
	[LastSynchronizedDate] [datetime] NULL,
 CONSTRAINT [PK_ProcessInstance] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [process].[ProcessInstance]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstance_ProcessTemplateRevision_Current] FOREIGN KEY([CurrentProcessTemplateRevisionID])
REFERENCES [process].[ProcessTemplateRevision] ([ID])
GO
ALTER TABLE [process].[ProcessInstance] CHECK CONSTRAINT [FK_ProcessInstance_ProcessTemplateRevision_Current]
GO
ALTER TABLE [process].[ProcessInstance]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstance_ProcessTemplateRevision_Original] FOREIGN KEY([OriginalProcessTemplateRevisionID])
REFERENCES [process].[ProcessTemplateRevision] ([ID])
GO
ALTER TABLE [process].[ProcessInstance] CHECK CONSTRAINT [FK_ProcessInstance_ProcessTemplateRevision_Original]
GO
