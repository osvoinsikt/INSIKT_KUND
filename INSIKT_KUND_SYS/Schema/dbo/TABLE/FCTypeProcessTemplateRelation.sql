SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCTypeProcessTemplateRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessTemplateID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
 CONSTRAINT [PK_FCTypeProcessTemplateRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCTypeProcessTemplateRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCTypeProcessTemplateRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCTypeProcessTemplateRelation] CHECK CONSTRAINT [FK_FCTypeProcessTemplateRelation_FCType]
GO
ALTER TABLE [dbo].[FCTypeProcessTemplateRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCTypeProcessTemplateRelation_ProcessTemplate] FOREIGN KEY([ProcessTemplateID])
REFERENCES [process].[ProcessTemplate] ([ID])
GO
ALTER TABLE [dbo].[FCTypeProcessTemplateRelation] CHECK CONSTRAINT [FK_FCTypeProcessTemplateRelation_ProcessTemplate]
GO
