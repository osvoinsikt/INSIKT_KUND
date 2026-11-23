SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectProcessTemplateFilterRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectPropertyFilterID] [int] NOT NULL,
	[ProcessTemplateID] [int] NOT NULL,
 CONSTRAINT [PK_FCProjectProcessTemplateFilterRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectProcessTemplateFilterRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProcessTemplateFilterRelation_FCProjectPropertyFilter] FOREIGN KEY([FCProjectPropertyFilterID])
REFERENCES [dbo].[FCProjectPropertyFilter] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProcessTemplateFilterRelation] CHECK CONSTRAINT [FK_FCProjectProcessTemplateFilterRelation_FCProjectPropertyFilter]
GO
ALTER TABLE [dbo].[FCProjectProcessTemplateFilterRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProcessTemplateFilterRelation_ProcessTemplate] FOREIGN KEY([ProcessTemplateID])
REFERENCES [process].[ProcessTemplate] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProcessTemplateFilterRelation] CHECK CONSTRAINT [FK_FCProjectProcessTemplateFilterRelation_ProcessTemplate]
GO
