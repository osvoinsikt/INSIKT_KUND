SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSourcesMeasureGroup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceID] [int] NOT NULL,
	[MeasureGroup] [nvarchar](1024) NOT NULL,
	[DTDQuery] [nvarchar](max) NULL,
	[DTDMethodID] [int] NOT NULL,
 CONSTRAINT [PK_DataSourcesMeasureGroup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataSourcesMeasureGroup] ADD  CONSTRAINT [DF_DataSourcesMeasureGroup_DrillthroughMethod]  DEFAULT ((1)) FOR [DTDMethodID]
GO
ALTER TABLE [dbo].[DataSourcesMeasureGroup]  WITH CHECK ADD  CONSTRAINT [FK_DataSourcesMeasureGroup_DataSources] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DataSources] ([ID])
GO
ALTER TABLE [dbo].[DataSourcesMeasureGroup] CHECK CONSTRAINT [FK_DataSourcesMeasureGroup_DataSources]
GO
ALTER TABLE [dbo].[DataSourcesMeasureGroup]  WITH CHECK ADD  CONSTRAINT [FK_DataSourcesMeasureGroup_DrillthroughMethod] FOREIGN KEY([DTDMethodID])
REFERENCES [dbo].[DrillthroughMethod] ([ID])
GO
ALTER TABLE [dbo].[DataSourcesMeasureGroup] CHECK CONSTRAINT [FK_DataSourcesMeasureGroup_DrillthroughMethod]
GO
