SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[HierarchyNodeLog](
	[HierarchyLogID] [int] NOT NULL,
	[HierarchyNodeID] [int] NOT NULL,
	[HierarchyID] [int] NOT NULL,
	[ParentHierarchyNodeID] [int] NULL,
	[SortOrder] [int] NOT NULL,
	[DimensionPartTypeID] [int] NULL,
	[Priority] [int] NOT NULL,
	[Expression] [nvarchar](1000) NULL,
	[FilterExpression] [nvarchar](max) NULL,
	[SortOrderExpression] [nvarchar](500) NULL,
	[EmptyHeader] [bit] NOT NULL,
 CONSTRAINT [PK_app_HierarchyNodeLog] PRIMARY KEY CLUSTERED 
(
	[HierarchyLogID] ASC,
	[HierarchyNodeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [app].[HierarchyNodeLog] ADD  CONSTRAINT [DF_HierarchyNode_PriorityLog]  DEFAULT ((0)) FOR [Priority]
GO
ALTER TABLE [app].[HierarchyNodeLog] ADD  CONSTRAINT [DF__HierarchyNode_EmptyHeader_Log]  DEFAULT ((0)) FOR [EmptyHeader]
GO
ALTER TABLE [app].[HierarchyNodeLog]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNode_app_Hierarchy_Log] FOREIGN KEY([HierarchyLogID], [HierarchyID])
REFERENCES [app].[HierarchyLog] ([HierarchyLogID], [HierarchyID])
GO
ALTER TABLE [app].[HierarchyNodeLog] CHECK CONSTRAINT [FK_app_HierarchyNode_app_Hierarchy_Log]
GO
ALTER TABLE [app].[HierarchyNodeLog]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNode_DimensionPartType_Log] FOREIGN KEY([DimensionPartTypeID])
REFERENCES [app].[DimensionPartType] ([DimensionPartTypeID])
GO
ALTER TABLE [app].[HierarchyNodeLog] CHECK CONSTRAINT [FK_app_HierarchyNode_DimensionPartType_Log]
GO
ALTER TABLE [app].[HierarchyNodeLog]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNode_HierarchyNodeDimensionPart_Log] FOREIGN KEY([HierarchyLogID], [HierarchyID], [DimensionPartTypeID])
REFERENCES [app].[HierarchyDimensionPartTypeLog] ([HierarchyLogID], [HierarchyID], [DimensionPartTypeID])
GO
ALTER TABLE [app].[HierarchyNodeLog] CHECK CONSTRAINT [FK_app_HierarchyNode_HierarchyNodeDimensionPart_Log]
GO
ALTER TABLE [app].[HierarchyNodeLog]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNode_ParentHierarchyNode_Log] FOREIGN KEY([HierarchyLogID], [ParentHierarchyNodeID])
REFERENCES [app].[HierarchyNodeLog] ([HierarchyLogID], [HierarchyNodeID])
GO
ALTER TABLE [app].[HierarchyNodeLog] CHECK CONSTRAINT [FK_app_HierarchyNode_ParentHierarchyNode_Log]
GO
ALTER TABLE [app].[HierarchyNodeLog]  WITH CHECK ADD  CONSTRAINT [FK_dw_HierarchyNodeLog_HierarchyLogInfo] FOREIGN KEY([HierarchyLogID])
REFERENCES [app].[HierarchyLogInfo] ([HierarchyLogID])
GO
ALTER TABLE [app].[HierarchyNodeLog] CHECK CONSTRAINT [FK_dw_HierarchyNodeLog_HierarchyLogInfo]
GO
