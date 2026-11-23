SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[HierarchyDimensionPartTypeLog](
	[HierarchyLogID] [int] NOT NULL,
	[HierarchyID] [int] NOT NULL,
	[DimensionPartTypeID] [int] NOT NULL,
	[DimensionPartFilterExpression] [nvarchar](1000) NULL,
	[DefaultSortOrderExpression] [nvarchar](500) NULL,
 CONSTRAINT [PK_app_HierarchyDimensionPartTypeLog] PRIMARY KEY CLUSTERED 
(
	[HierarchyLogID] ASC,
	[HierarchyID] ASC,
	[DimensionPartTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [app].[HierarchyDimensionPartTypeLog]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyDimensionPartType_Hierarchy_Log] FOREIGN KEY([HierarchyLogID], [HierarchyID])
REFERENCES [app].[HierarchyLog] ([HierarchyLogID], [HierarchyID])
GO
ALTER TABLE [app].[HierarchyDimensionPartTypeLog] CHECK CONSTRAINT [FK_app_HierarchyDimensionPartType_Hierarchy_Log]
GO
ALTER TABLE [app].[HierarchyDimensionPartTypeLog]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyDimensionPartTypeLog_DimensionPartType] FOREIGN KEY([DimensionPartTypeID])
REFERENCES [app].[DimensionPartType] ([DimensionPartTypeID])
GO
ALTER TABLE [app].[HierarchyDimensionPartTypeLog] CHECK CONSTRAINT [FK_app_HierarchyDimensionPartTypeLog_DimensionPartType]
GO
ALTER TABLE [app].[HierarchyDimensionPartTypeLog]  WITH CHECK ADD  CONSTRAINT [FK_dw_HierarchyDimensionPartTypeLog_HierarchyLogInfo] FOREIGN KEY([HierarchyLogID])
REFERENCES [app].[HierarchyLogInfo] ([HierarchyLogID])
GO
ALTER TABLE [app].[HierarchyDimensionPartTypeLog] CHECK CONSTRAINT [FK_dw_HierarchyDimensionPartTypeLog_HierarchyLogInfo]
GO
