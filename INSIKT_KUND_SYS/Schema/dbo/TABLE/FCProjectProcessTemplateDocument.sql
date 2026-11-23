SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectProcessTemplateDocument](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DocumentID] [int] NOT NULL,
	[ProcessTemplateRevisionID] [int] NOT NULL,
	[ProcessTemplateActivityRevisionID] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[IsInstantiatable] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectProcessTemplateDocument] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectProcessTemplateDocument] ADD  CONSTRAINT [DF_FCProjectProcessTemplateDocument_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCProjectProcessTemplateDocument] ADD  CONSTRAINT [DF_FCProjectProcessTemplateDocument_IsInstantiatable]  DEFAULT ((0)) FOR [IsInstantiatable]
GO
ALTER TABLE [dbo].[FCProjectProcessTemplateDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProcessTemplateDocument_ActivityRevision] FOREIGN KEY([ProcessTemplateActivityRevisionID])
REFERENCES [process].[ProcessTemplateActivityRevision] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProcessTemplateDocument] CHECK CONSTRAINT [FK_FCProjectProcessTemplateDocument_ActivityRevision]
GO
ALTER TABLE [dbo].[FCProjectProcessTemplateDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProcessTemplateDocument_Document] FOREIGN KEY([DocumentID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProcessTemplateDocument] CHECK CONSTRAINT [FK_FCProjectProcessTemplateDocument_Document]
GO
ALTER TABLE [dbo].[FCProjectProcessTemplateDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProcessTemplateDocument_ProcessTemplateRevision] FOREIGN KEY([ProcessTemplateRevisionID])
REFERENCES [process].[ProcessTemplateRevision] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProcessTemplateDocument] CHECK CONSTRAINT [FK_FCProjectProcessTemplateDocument_ProcessTemplateRevision]
GO
