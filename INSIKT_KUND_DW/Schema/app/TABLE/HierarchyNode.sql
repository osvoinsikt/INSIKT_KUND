SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[HierarchyNode](
	[HierarchyNodeID] [int] IDENTITY(1,1) NOT NULL,
	[HierarchyID] [int] NOT NULL,
	[ParentHierarchyNodeID] [int] NULL,
	[SortOrder] [int] NOT NULL,
	[DimensionPartTypeID] [int] NULL,
	[Priority] [int] NOT NULL,
	[Expression] [nvarchar](1000) NULL,
	[FilterExpression] [nvarchar](max) NULL,
	[SortOrderExpression] [nvarchar](500) NULL,
	[EmptyHeader] [bit] NOT NULL,
 CONSTRAINT [PK_app_HierarchyNode] PRIMARY KEY CLUSTERED 
(
	[HierarchyNodeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [app].[HierarchyNode] ADD  CONSTRAINT [DF_HierarchyNode_Priority]  DEFAULT ((0)) FOR [Priority]
GO
ALTER TABLE [app].[HierarchyNode] ADD  CONSTRAINT [DF__Hierarchy__Empty__16644E42]  DEFAULT ((0)) FOR [EmptyHeader]
GO
ALTER TABLE [app].[HierarchyNode]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNode_app_Hierarchy] FOREIGN KEY([HierarchyID])
REFERENCES [app].[Hierarchy] ([HierarchyID])
GO
ALTER TABLE [app].[HierarchyNode] CHECK CONSTRAINT [FK_app_HierarchyNode_app_Hierarchy]
GO
ALTER TABLE [app].[HierarchyNode]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNode_DimensionPartType] FOREIGN KEY([DimensionPartTypeID])
REFERENCES [app].[DimensionPartType] ([DimensionPartTypeID])
GO
ALTER TABLE [app].[HierarchyNode] CHECK CONSTRAINT [FK_app_HierarchyNode_DimensionPartType]
GO
ALTER TABLE [app].[HierarchyNode]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNode_HierarchyNodeDimensionPart] FOREIGN KEY([HierarchyID], [DimensionPartTypeID])
REFERENCES [app].[HierarchyDimensionPartType] ([HierarchyID], [DimensionPartTypeID])
GO
ALTER TABLE [app].[HierarchyNode] CHECK CONSTRAINT [FK_app_HierarchyNode_HierarchyNodeDimensionPart]
GO
ALTER TABLE [app].[HierarchyNode]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNode_ParentHierarchyNode] FOREIGN KEY([ParentHierarchyNodeID])
REFERENCES [app].[HierarchyNode] ([HierarchyNodeID])
GO
ALTER TABLE [app].[HierarchyNode] CHECK CONSTRAINT [FK_app_HierarchyNode_ParentHierarchyNode]
GO
