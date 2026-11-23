SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[HierarchyDimensionPartType](
	[HierarchyID] [int] NOT NULL,
	[DimensionPartTypeID] [int] NOT NULL,
	[DimensionPartFilterExpression] [nvarchar](1000) NULL,
	[DefaultSortOrderExpression] [nvarchar](500) NULL,
 CONSTRAINT [PK_app_HierarchyDimensionPartType] PRIMARY KEY CLUSTERED 
(
	[HierarchyID] ASC,
	[DimensionPartTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [app].[HierarchyDimensionPartType]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyDimensionPartType_DimensionPartType] FOREIGN KEY([DimensionPartTypeID])
REFERENCES [app].[DimensionPartType] ([DimensionPartTypeID])
GO
ALTER TABLE [app].[HierarchyDimensionPartType] CHECK CONSTRAINT [FK_app_HierarchyDimensionPartType_DimensionPartType]
GO
ALTER TABLE [app].[HierarchyDimensionPartType]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyDimensionPartType_Hierarchy] FOREIGN KEY([HierarchyID])
REFERENCES [app].[Hierarchy] ([HierarchyID])
GO
ALTER TABLE [app].[HierarchyDimensionPartType] CHECK CONSTRAINT [FK_app_HierarchyDimensionPartType_Hierarchy]
GO
