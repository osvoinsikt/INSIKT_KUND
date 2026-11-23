SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CellCommentDocument](
	[CellCommentEntryID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
 CONSTRAINT [PK_CellCommentDocument] PRIMARY KEY CLUSTERED 
(
	[CellCommentEntryID] ASC,
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[CellCommentDocument]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentDocument_CellCommentEntry] FOREIGN KEY([CellCommentEntryID])
REFERENCES [dbo].[CellCommentEntry] ([ID])
GO
ALTER TABLE [dbo].[CellCommentDocument] CHECK CONSTRAINT [FK_CellCommentDocument_CellCommentEntry]
GO
ALTER TABLE [dbo].[CellCommentDocument]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentDocument_Document] FOREIGN KEY([DocumentID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[CellCommentDocument] CHECK CONSTRAINT [FK_CellCommentDocument_Document]
GO
