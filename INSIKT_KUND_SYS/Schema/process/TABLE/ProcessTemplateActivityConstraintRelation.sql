SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [process].[ProcessTemplateActivityConstraintRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessTemplateActivityRevisionID] [int] NOT NULL,
	[ProcessTemplateActivityStepRevisionID] [int] NULL,
	[ConstraintID] [int] NOT NULL,
 CONSTRAINT [PK_ProcessTemplateActivityConstraintRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [process].[ProcessTemplateActivityConstraintRelation]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTemplateActivityConstraintRelation_ProcessTemplateActivityRevision] FOREIGN KEY([ProcessTemplateActivityRevisionID])
REFERENCES [process].[ProcessTemplateActivityRevision] ([ID])
GO
ALTER TABLE [process].[ProcessTemplateActivityConstraintRelation] CHECK CONSTRAINT [FK_ProcessTemplateActivityConstraintRelation_ProcessTemplateActivityRevision]
GO
ALTER TABLE [process].[ProcessTemplateActivityConstraintRelation]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTemplateActivityConstraintRelation_ProcessTemplateActivityStepRevision] FOREIGN KEY([ProcessTemplateActivityStepRevisionID])
REFERENCES [process].[ProcessTemplateActivityStepRevision] ([ID])
GO
ALTER TABLE [process].[ProcessTemplateActivityConstraintRelation] CHECK CONSTRAINT [FK_ProcessTemplateActivityConstraintRelation_ProcessTemplateActivityStepRevision]
GO
