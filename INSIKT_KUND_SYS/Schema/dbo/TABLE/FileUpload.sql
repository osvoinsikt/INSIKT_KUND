SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FileUpload](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Comment] [nvarchar](max) NULL,
	[StatusID] [int] NOT NULL,
	[FileTypeID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[FCProcessID] [int] NULL,
	[FCProjectID] [int] NULL,
 CONSTRAINT [PK_FileUpload] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FileUpload]  WITH CHECK ADD  CONSTRAINT [FK_FileUpload_Document] FOREIGN KEY([DocumentID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[FileUpload] CHECK CONSTRAINT [FK_FileUpload_Document]
GO
ALTER TABLE [dbo].[FileUpload]  WITH CHECK ADD  CONSTRAINT [FK_FileUpload_FCProcess] FOREIGN KEY([FCProcessID])
REFERENCES [dbo].[FCProcess] ([ID])
GO
ALTER TABLE [dbo].[FileUpload] CHECK CONSTRAINT [FK_FileUpload_FCProcess]
GO
ALTER TABLE [dbo].[FileUpload]  WITH CHECK ADD  CONSTRAINT [FK_FileUpload_FCProject] FOREIGN KEY([FCProjectID])
REFERENCES [dbo].[FCProject] ([ID])
GO
ALTER TABLE [dbo].[FileUpload] CHECK CONSTRAINT [FK_FileUpload_FCProject]
GO
ALTER TABLE [dbo].[FileUpload]  WITH CHECK ADD  CONSTRAINT [FK_FileUpload_FileType] FOREIGN KEY([FileTypeID])
REFERENCES [dbo].[FileUploadType] ([ID])
GO
ALTER TABLE [dbo].[FileUpload] CHECK CONSTRAINT [FK_FileUpload_FileType]
GO
ALTER TABLE [dbo].[FileUpload]  WITH CHECK ADD  CONSTRAINT [FK_FileUpload_Status] FOREIGN KEY([StatusID])
REFERENCES [dbo].[FileUploadStatus] ([ID])
GO
ALTER TABLE [dbo].[FileUpload] CHECK CONSTRAINT [FK_FileUpload_Status]
GO
