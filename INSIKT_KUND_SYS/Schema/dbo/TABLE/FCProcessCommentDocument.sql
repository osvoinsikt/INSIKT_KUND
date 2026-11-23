SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProcessCommentDocument](
	[FCProcessCommentID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
 CONSTRAINT [PK_FCProcessCommentDocument] PRIMARY KEY CLUSTERED 
(
	[FCProcessCommentID] ASC,
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProcessCommentDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProcessCommentDocument_Document] FOREIGN KEY([DocumentID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[FCProcessCommentDocument] CHECK CONSTRAINT [FK_FCProcessCommentDocument_Document]
GO
ALTER TABLE [dbo].[FCProcessCommentDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCProcessCommentDocument_FCProcessComment] FOREIGN KEY([FCProcessCommentID])
REFERENCES [dbo].[FCProcessComment] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FCProcessCommentDocument] CHECK CONSTRAINT [FK_FCProcessCommentDocument_FCProcessComment]
GO
