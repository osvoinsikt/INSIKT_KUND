SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FileUploadErrorLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FileUploadID] [int] NOT NULL,
	[ErrorLogTypeID] [int] NOT NULL,
	[RowNumber] [int] NULL,
	[ColumnNumber] [int] NULL,
	[ColumnName] [varchar](100) NULL,
	[ErrorMessage] [nvarchar](max) NULL,
	[ExpectedDataType] [varchar](50) NULL,
 CONSTRAINT [PK_FileUploadErrorLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FileUploadErrorLog]  WITH CHECK ADD  CONSTRAINT [FK_FileUploadErrorLog_FileUpload] FOREIGN KEY([FileUploadID])
REFERENCES [dbo].[FileUpload] ([ID])
GO
ALTER TABLE [dbo].[FileUploadErrorLog] CHECK CONSTRAINT [FK_FileUploadErrorLog_FileUpload]
GO
ALTER TABLE [dbo].[FileUploadErrorLog]  WITH CHECK ADD  CONSTRAINT [FK_FileUploadErrorLog_FileUploadErrorLogType] FOREIGN KEY([ErrorLogTypeID])
REFERENCES [dbo].[FileUploadErrorLogType] ([ID])
GO
ALTER TABLE [dbo].[FileUploadErrorLog] CHECK CONSTRAINT [FK_FileUploadErrorLog_FileUploadErrorLogType]
GO
