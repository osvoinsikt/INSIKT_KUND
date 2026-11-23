SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DrillthroughColumns](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceID] [int] NOT NULL,
	[DataSourcesMeasureGroupID] [int] NULL,
	[UniqueName] [nvarchar](255) NOT NULL,
	[Caption] [nvarchar](100) NULL,
	[Order] [int] NULL,
	[DataType] [nvarchar](30) NULL,
 CONSTRAINT [PK_DrillthroughColumns] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[DrillthroughColumns]  WITH CHECK ADD  CONSTRAINT [FK_DrillthroughColumns_DataSources] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DataSources] ([ID])
GO
ALTER TABLE [dbo].[DrillthroughColumns] CHECK CONSTRAINT [FK_DrillthroughColumns_DataSources]
GO
ALTER TABLE [dbo].[DrillthroughColumns]  WITH CHECK ADD  CONSTRAINT [FK_DrillthroughColumns_DataSourcesMeasureGroup] FOREIGN KEY([DataSourcesMeasureGroupID])
REFERENCES [dbo].[DataSourcesMeasureGroup] ([ID])
GO
ALTER TABLE [dbo].[DrillthroughColumns] CHECK CONSTRAINT [FK_DrillthroughColumns_DataSourcesMeasureGroup]
GO
