SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [process].[ProcessTemplateActivityRevision](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessTemplateActivityID] [int] NOT NULL,
	[ParentTemplateActivityRevisionID] [int] NULL,
	[Order] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ProcessTemplatePhaseRevisionID] [int] NOT NULL,
	[ProcessTemplateActivityTypeID] [int] NOT NULL,
	[IsMandatory] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[ChangeTypeID] [int] NULL,
 CONSTRAINT [PK_ProcessTemplateActivityRevision_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [process].[ProcessTemplateActivityRevision] ADD  CONSTRAINT [DF_ProcessTemplateActivityRevision_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [process].[ProcessTemplateActivityRevision]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTemplateActivityRevision_ProcessActivityType] FOREIGN KEY([ProcessTemplateActivityTypeID])
REFERENCES [process].[ProcessActivityType] ([ID])
GO
ALTER TABLE [process].[ProcessTemplateActivityRevision] CHECK CONSTRAINT [FK_ProcessTemplateActivityRevision_ProcessActivityType]
GO
ALTER TABLE [process].[ProcessTemplateActivityRevision]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTemplateActivityRevision_ProcessRevisionChangeType] FOREIGN KEY([ChangeTypeID])
REFERENCES [process].[ProcessRevisionChangeType] ([ID])
GO
ALTER TABLE [process].[ProcessTemplateActivityRevision] CHECK CONSTRAINT [FK_ProcessTemplateActivityRevision_ProcessRevisionChangeType]
GO
ALTER TABLE [process].[ProcessTemplateActivityRevision]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTemplateActivityRevision_ProcessTemplateActivity] FOREIGN KEY([ProcessTemplateActivityID])
REFERENCES [process].[ProcessTemplateActivity] ([ID])
GO
ALTER TABLE [process].[ProcessTemplateActivityRevision] CHECK CONSTRAINT [FK_ProcessTemplateActivityRevision_ProcessTemplateActivity]
GO
ALTER TABLE [process].[ProcessTemplateActivityRevision]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTemplateActivityRevision_ProcessTemplateActivityRevision] FOREIGN KEY([ParentTemplateActivityRevisionID])
REFERENCES [process].[ProcessTemplateActivityRevision] ([ID])
GO
ALTER TABLE [process].[ProcessTemplateActivityRevision] CHECK CONSTRAINT [FK_ProcessTemplateActivityRevision_ProcessTemplateActivityRevision]
GO
ALTER TABLE [process].[ProcessTemplateActivityRevision]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTemplateActivityRevision_ProcessTemplatePhaseRevision] FOREIGN KEY([ProcessTemplatePhaseRevisionID])
REFERENCES [process].[ProcessTemplatePhaseRevision] ([ID])
GO
ALTER TABLE [process].[ProcessTemplateActivityRevision] CHECK CONSTRAINT [FK_ProcessTemplateActivityRevision_ProcessTemplatePhaseRevision]
GO
