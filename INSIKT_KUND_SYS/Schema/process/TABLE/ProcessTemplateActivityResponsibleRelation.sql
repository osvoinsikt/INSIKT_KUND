SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [process].[ProcessTemplateActivityResponsibleRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessTemplateActivityRevisionID] [int] NOT NULL,
	[ProcessTemplateActivityStepRevisionID] [int] NULL,
	[RoleID] [int] NULL,
 CONSTRAINT [PK_ProcessTemplateResponsibleRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [process].[ProcessTemplateActivityResponsibleRelation]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTemplateActivityResponsibleRelation_ProcessTemplateActivityStepRevision] FOREIGN KEY([ProcessTemplateActivityStepRevisionID])
REFERENCES [process].[ProcessTemplateActivityStepRevision] ([ID])
GO
ALTER TABLE [process].[ProcessTemplateActivityResponsibleRelation] CHECK CONSTRAINT [FK_ProcessTemplateActivityResponsibleRelation_ProcessTemplateActivityStepRevision]
GO
ALTER TABLE [process].[ProcessTemplateActivityResponsibleRelation]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTemplateResponsibleRelation_ProcessTemplateActivityRevision] FOREIGN KEY([ProcessTemplateActivityRevisionID])
REFERENCES [process].[ProcessTemplateActivityRevision] ([ID])
GO
ALTER TABLE [process].[ProcessTemplateActivityResponsibleRelation] CHECK CONSTRAINT [FK_ProcessTemplateResponsibleRelation_ProcessTemplateActivityRevision]
GO
