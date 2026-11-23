SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentRevision](
	[DocumentID] [int] NOT NULL,
	[RevisionID] [int] NOT NULL,
	[IsLatestRevision] [bit] NOT NULL,
	[UploadedBy] [int] NOT NULL,
	[UploadedDate] [datetime] NOT NULL,
	[DocumentDataID] [int] NULL,
 CONSTRAINT [PK_DocumentRevision] PRIMARY KEY CLUSTERED 
(
	[DocumentID] ASC,
	[RevisionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[DocumentRevision]  WITH CHECK ADD  CONSTRAINT [FK_DocumentRevision_Document] FOREIGN KEY([DocumentID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[DocumentRevision] CHECK CONSTRAINT [FK_DocumentRevision_Document]
GO
ALTER TABLE [dbo].[DocumentRevision]  WITH CHECK ADD  CONSTRAINT [FK_DocumentRevision_DocumentData] FOREIGN KEY([DocumentDataID])
REFERENCES [dbo].[DocumentData] ([ID])
GO
ALTER TABLE [dbo].[DocumentRevision] CHECK CONSTRAINT [FK_DocumentRevision_DocumentData]
GO
ALTER TABLE [dbo].[DocumentRevision]  WITH CHECK ADD  CONSTRAINT [FK_DocumentRevision_UserSecurityGroup_UploadedBy] FOREIGN KEY([UploadedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[DocumentRevision] CHECK CONSTRAINT [FK_DocumentRevision_UserSecurityGroup_UploadedBy]
GO
