SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectPropertyDataSourceDimensionRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProjectPropertyID] [int] NOT NULL,
	[DataSourceDimensionID] [int] NOT NULL,
	[ShowAsMeasure] [bit] NOT NULL,
	[ShowInTooltip] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectPropertyDataSourceDimensionRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_FCProjectPropertyDataSourceDimensionRelation_ProjectPropertyID_DataSourceDimensionID] UNIQUE NONCLUSTERED 
(
	[ProjectPropertyID] ASC,
	[DataSourceDimensionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectPropertyDataSourceDimensionRelation] ADD  CONSTRAINT [DF_FCProjectPropertyDataSourceDimensionRelation_ShowAsMeasure]  DEFAULT ((1)) FOR [ShowAsMeasure]
GO
ALTER TABLE [dbo].[FCProjectPropertyDataSourceDimensionRelation] ADD  CONSTRAINT [DF_FCProjectPropertyDataSourceDimensionRelation_ShowInTooltip]  DEFAULT ((0)) FOR [ShowInTooltip]
GO
ALTER TABLE [dbo].[FCProjectPropertyDataSourceDimensionRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyDataSourceDimensionRelation_DataSourceDimensionID] FOREIGN KEY([DataSourceDimensionID])
REFERENCES [dbo].[DataSourceDimension] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyDataSourceDimensionRelation] CHECK CONSTRAINT [FK_FCProjectPropertyDataSourceDimensionRelation_DataSourceDimensionID]
GO
ALTER TABLE [dbo].[FCProjectPropertyDataSourceDimensionRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyDataSourceDimensionRelation_ProjectPropertyID] FOREIGN KEY([ProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyDataSourceDimensionRelation] CHECK CONSTRAINT [FK_FCProjectPropertyDataSourceDimensionRelation_ProjectPropertyID]
GO
