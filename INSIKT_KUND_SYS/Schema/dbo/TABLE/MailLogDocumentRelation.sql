SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailLogDocumentRelation](
	[MailLogID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
 CONSTRAINT [PK_MailLogDocumentRelation] PRIMARY KEY CLUSTERED 
(
	[MailLogID] ASC,
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[MailLogDocumentRelation]  WITH CHECK ADD  CONSTRAINT [FK_MailLogDocumentRelation_Document] FOREIGN KEY([DocumentID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[MailLogDocumentRelation] CHECK CONSTRAINT [FK_MailLogDocumentRelation_Document]
GO
ALTER TABLE [dbo].[MailLogDocumentRelation]  WITH CHECK ADD  CONSTRAINT [FK_MailLogDocumentRelation_MailLog] FOREIGN KEY([MailLogID])
REFERENCES [dbo].[MailLog] ([ID])
GO
ALTER TABLE [dbo].[MailLogDocumentRelation] CHECK CONSTRAINT [FK_MailLogDocumentRelation_MailLog]
GO
