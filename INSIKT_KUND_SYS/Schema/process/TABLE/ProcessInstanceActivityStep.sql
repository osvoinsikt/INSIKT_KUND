SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [process].[ProcessInstanceActivityStep](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessInstanceActivityID] [int] NOT NULL,
	[ProcessTemplateActivityStepRevisionID] [int] NULL,
	[IsHidden] [bit] NOT NULL,
	[FinishedDate] [datetime] NULL,
	[FinishedBy] [int] NULL,
	[Order] [int] NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_ProcessInstanceActivityStep] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE UNIQUE CLUSTERED INDEX [IX_ProcessInstanceActivityStep_ProcessInstanceActivityID] ON [process].[ProcessInstanceActivityStep]
(
	[ProcessInstanceActivityID] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProcessInstanceActivityStepID] ON [process].[ProcessInstanceActivityStep]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [process].[ProcessInstanceActivityStep]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstanceActivityStep_ProcessInstanceActivity] FOREIGN KEY([ProcessInstanceActivityID])
REFERENCES [process].[ProcessInstanceActivity] ([ID])
GO
ALTER TABLE [process].[ProcessInstanceActivityStep] CHECK CONSTRAINT [FK_ProcessInstanceActivityStep_ProcessInstanceActivity]
GO
ALTER TABLE [process].[ProcessInstanceActivityStep]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstanceActivityStep_ProcessTemplateActivityStepRevision] FOREIGN KEY([ProcessTemplateActivityStepRevisionID])
REFERENCES [process].[ProcessTemplateActivityStepRevision] ([ID])
GO
ALTER TABLE [process].[ProcessInstanceActivityStep] CHECK CONSTRAINT [FK_ProcessInstanceActivityStep_ProcessTemplateActivityStepRevision]
GO
