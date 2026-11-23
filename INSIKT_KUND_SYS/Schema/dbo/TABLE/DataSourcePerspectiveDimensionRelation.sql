SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSourcePerspectiveDimensionRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourcePerspectiveID] [int] NOT NULL,
	[DataSourceDimensionID] [int] NOT NULL,
	[DataSourceDimensionHierarchyID] [int] NULL,
 CONSTRAINT [PK_DataSourcePerspectiveDimensionRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataSourcePerspectiveDimensionRelation]  WITH CHECK ADD  CONSTRAINT [FK_DataSourcePerspectiveDimensionRelation_Dimension] FOREIGN KEY([DataSourceDimensionID])
REFERENCES [dbo].[DataSourceDimension] ([ID])
GO
ALTER TABLE [dbo].[DataSourcePerspectiveDimensionRelation] CHECK CONSTRAINT [FK_DataSourcePerspectiveDimensionRelation_Dimension]
GO
ALTER TABLE [dbo].[DataSourcePerspectiveDimensionRelation]  WITH CHECK ADD  CONSTRAINT [FK_DataSourcePerspectiveDimensionRelation_Hierarchy] FOREIGN KEY([DataSourceDimensionHierarchyID])
REFERENCES [dbo].[DataSourceDimensionHierarchy] ([ID])
GO
ALTER TABLE [dbo].[DataSourcePerspectiveDimensionRelation] CHECK CONSTRAINT [FK_DataSourcePerspectiveDimensionRelation_Hierarchy]
GO
ALTER TABLE [dbo].[DataSourcePerspectiveDimensionRelation]  WITH CHECK ADD  CONSTRAINT [FK_DataSourcePerspectiveDimensionRelation_Perspective] FOREIGN KEY([DataSourcePerspectiveID])
REFERENCES [dbo].[DataSourcePerspective] ([ID])
GO
ALTER TABLE [dbo].[DataSourcePerspectiveDimensionRelation] CHECK CONSTRAINT [FK_DataSourcePerspectiveDimensionRelation_Perspective]
GO
