SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [process].[ProcessTemplateActivityStepRevision](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessTemplateActivityStepID] [int] NOT NULL,
	[ProcessTemplateActivityRevisionID] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Order] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_ProcessTemplateActivityStepRevision] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [process].[ProcessTemplateActivityStepRevision] ADD  CONSTRAINT [DF_ProcessTemplateActivityStepRevision_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [process].[ProcessTemplateActivityStepRevision]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTemplateActivityStepRevision_ProcessTemplateActivityRevision] FOREIGN KEY([ProcessTemplateActivityRevisionID])
REFERENCES [process].[ProcessTemplateActivityRevision] ([ID])
GO
ALTER TABLE [process].[ProcessTemplateActivityStepRevision] CHECK CONSTRAINT [FK_ProcessTemplateActivityStepRevision_ProcessTemplateActivityRevision]
GO
ALTER TABLE [process].[ProcessTemplateActivityStepRevision]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTemplateActivityStepRevision_ProcessTemplateActivityStep] FOREIGN KEY([ProcessTemplateActivityStepID])
REFERENCES [process].[ProcessTemplateActivityStep] ([ID])
GO
ALTER TABLE [process].[ProcessTemplateActivityStepRevision] CHECK CONSTRAINT [FK_ProcessTemplateActivityStepRevision_ProcessTemplateActivityStep]
GO
