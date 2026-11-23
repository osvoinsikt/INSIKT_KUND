SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectDocument](
	[FCProjectID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[FCProjectDocumentTypeID] [int] NULL,
	[ApprovedBy] [int] NULL,
	[ApprovedDate] [datetime] NULL,
 CONSTRAINT [PK_FCProjectDocument] PRIMARY KEY CLUSTERED 
(
	[FCProjectID] ASC,
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectDocument_Document] FOREIGN KEY([DocumentID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[FCProjectDocument] CHECK CONSTRAINT [FK_FCProjectDocument_Document]
GO
ALTER TABLE [dbo].[FCProjectDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectDocument_FCProject] FOREIGN KEY([FCProjectID])
REFERENCES [dbo].[FCProject] ([ID])
GO
ALTER TABLE [dbo].[FCProjectDocument] CHECK CONSTRAINT [FK_FCProjectDocument_FCProject]
GO
ALTER TABLE [dbo].[FCProjectDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectDocument_FCProjectDocumentType] FOREIGN KEY([FCProjectDocumentTypeID])
REFERENCES [dbo].[FCProjectDocumentType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectDocument] CHECK CONSTRAINT [FK_FCProjectDocument_FCProjectDocumentType]
GO
ALTER TABLE [dbo].[FCProjectDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectDocument_UserSecurityGroup_ApprovedBy] FOREIGN KEY([ApprovedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProjectDocument] CHECK CONSTRAINT [FK_FCProjectDocument_UserSecurityGroup_ApprovedBy]
GO
