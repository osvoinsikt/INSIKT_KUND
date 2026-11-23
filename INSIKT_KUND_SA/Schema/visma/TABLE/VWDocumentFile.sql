SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [visma].[VWDocumentFile](
	[DocumentFileId] [int] NOT NULL,
	[RelatedDocumentFileId] [int] NULL,
	[DocumentId] [int] NULL,
	[StorageVolumeId] [int] NOT NULL,
	[PageNumber] [int] NOT NULL,
	[FileName] [varchar](1024) NOT NULL,
	[OCRText] [ntext] NULL,
	[RowVersionNo] [int] NOT NULL,
	[Created] [datetime] NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[LastUpdate] [datetime] NOT NULL,
	[LastUpdatedBy] [varchar](100) NULL,
	[SA_SourceSystemID] [int] NOT NULL,
 CONSTRAINT [PK_visma_VWDocumentFile] PRIMARY KEY CLUSTERED 
(
	[SA_SourceSystemID] ASC,
	[DocumentFileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
