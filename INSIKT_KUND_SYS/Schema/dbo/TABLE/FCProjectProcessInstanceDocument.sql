SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectProcessInstanceDocument](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DocumentID] [int] NOT NULL,
	[ProcessInstanceID] [int] NOT NULL,
	[ProcessInstanceActivityID] [int] NOT NULL,
	[ProcessTemplateDocumentID] [int] NULL,
	[ProcessInstanceDocumentID] [int] NULL,
	[IsDeleted] [bit] NOT NULL,
	[FCProjectDocumentTypeID] [int] NULL,
 CONSTRAINT [PK_FCProjectProcessInstanceDocument] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectProcessInstanceDocument] ADD  CONSTRAINT [DF_FCProjectProcessInstanceDocument_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProcessInstanceDocument_Activity] FOREIGN KEY([ProcessInstanceActivityID])
REFERENCES [process].[ProcessInstanceActivity] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceDocument] CHECK CONSTRAINT [FK_FCProjectProcessInstanceDocument_Activity]
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProcessInstanceDocument_Document] FOREIGN KEY([DocumentID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceDocument] CHECK CONSTRAINT [FK_FCProjectProcessInstanceDocument_Document]
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProcessInstanceDocument_FCProjectDocumentType] FOREIGN KEY([FCProjectDocumentTypeID])
REFERENCES [dbo].[FCProjectDocumentType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceDocument] CHECK CONSTRAINT [FK_FCProjectProcessInstanceDocument_FCProjectDocumentType]
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProcessInstanceDocument_FCProjectProcessInstanceDocument] FOREIGN KEY([ProcessInstanceDocumentID])
REFERENCES [dbo].[FCProjectProcessInstanceDocument] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceDocument] CHECK CONSTRAINT [FK_FCProjectProcessInstanceDocument_FCProjectProcessInstanceDocument]
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProcessInstanceDocument_FCProjectProcessTemplateDocument] FOREIGN KEY([ProcessTemplateDocumentID])
REFERENCES [dbo].[FCProjectProcessTemplateDocument] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceDocument] CHECK CONSTRAINT [FK_FCProjectProcessInstanceDocument_FCProjectProcessTemplateDocument]
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProcessInstanceDocument_Instance] FOREIGN KEY([ProcessInstanceID])
REFERENCES [process].[ProcessInstance] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceDocument] CHECK CONSTRAINT [FK_FCProjectProcessInstanceDocument_Instance]
GO
