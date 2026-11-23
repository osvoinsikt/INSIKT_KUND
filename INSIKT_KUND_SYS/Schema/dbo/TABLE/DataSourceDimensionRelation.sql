SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSourceDimensionRelation](
	[FirstDataSourceDimensionID] [int] NOT NULL,
	[SecondDataSourceDimensionID] [int] NOT NULL,
	[Identical] [bit] NOT NULL,
 CONSTRAINT [PK_DataSourceDimensionRelation] PRIMARY KEY CLUSTERED 
(
	[FirstDataSourceDimensionID] ASC,
	[SecondDataSourceDimensionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataSourceDimensionRelation] ADD  CONSTRAINT [DF_DataSourceDimensionRelation_Identical]  DEFAULT ((0)) FOR [Identical]
GO
ALTER TABLE [dbo].[DataSourceDimensionRelation]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceDimensionRelation_DataSourceDimension_First] FOREIGN KEY([FirstDataSourceDimensionID])
REFERENCES [dbo].[DataSourceDimension] ([ID])
GO
ALTER TABLE [dbo].[DataSourceDimensionRelation] CHECK CONSTRAINT [FK_DataSourceDimensionRelation_DataSourceDimension_First]
GO
ALTER TABLE [dbo].[DataSourceDimensionRelation]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceDimensionRelation_DataSourceDimension_Second] FOREIGN KEY([SecondDataSourceDimensionID])
REFERENCES [dbo].[DataSourceDimension] ([ID])
GO
ALTER TABLE [dbo].[DataSourceDimensionRelation] CHECK CONSTRAINT [FK_DataSourceDimensionRelation_DataSourceDimension_Second]
GO
