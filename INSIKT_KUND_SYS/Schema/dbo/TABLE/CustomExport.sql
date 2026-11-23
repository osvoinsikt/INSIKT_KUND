SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomExport](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[ReportPath] [nvarchar](max) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[RowContextDependent] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[FileFormatID] [int] NOT NULL,
 CONSTRAINT [PK_CustomExport] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[CustomExport] ADD  CONSTRAINT [DF_CustomExport_RowContextDependent]  DEFAULT ((0)) FOR [RowContextDependent]
GO
ALTER TABLE [dbo].[CustomExport] ADD  CONSTRAINT [DF_CustomExport_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[CustomExport] ADD  CONSTRAINT [DF_CustomExport_IsDefault]  DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[CustomExport] ADD  CONSTRAINT [DF_CustomExport_FileFormatID]  DEFAULT ((1)) FOR [FileFormatID]
GO
ALTER TABLE [dbo].[CustomExport]  WITH CHECK ADD  CONSTRAINT [FK_CustomExport_FileFormatID] FOREIGN KEY([FileFormatID])
REFERENCES [dbo].[CustomExportFileFormat] ([ID])
GO
ALTER TABLE [dbo].[CustomExport] CHECK CONSTRAINT [FK_CustomExport_FileFormatID]
GO
