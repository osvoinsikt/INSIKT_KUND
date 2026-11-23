SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FileUploadType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Caption] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Extension] [nvarchar](20) NULL,
	[StagingDatabase] [nvarchar](255) NULL,
	[StagingSchema] [nvarchar](255) NULL,
	[StagingTable] [nvarchar](255) NULL,
	[FailOnError] [bit] NOT NULL,
	[ImportData] [bit] NOT NULL,
	[FCTypeID] [int] NULL,
	[SortOrder] [int] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_FileUploadType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FileUploadType] ADD  CONSTRAINT [DF_FileUploadType_FailOnError]  DEFAULT ((1)) FOR [FailOnError]
GO
ALTER TABLE [dbo].[FileUploadType] ADD  CONSTRAINT [DF_FileUploadType_ImportData]  DEFAULT ((1)) FOR [ImportData]
GO
ALTER TABLE [dbo].[FileUploadType]  WITH CHECK ADD  CONSTRAINT [FK_FileUploadType_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FileUploadType] CHECK CONSTRAINT [FK_FileUploadType_FCType]
GO
