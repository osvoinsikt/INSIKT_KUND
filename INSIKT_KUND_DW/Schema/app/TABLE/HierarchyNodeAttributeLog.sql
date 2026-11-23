SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[HierarchyNodeAttributeLog](
	[HierarchyLogID] [int] NOT NULL,
	[HierarchyNodeID] [int] NOT NULL,
	[HierarchyNodeAttributeTypeID] [int] NOT NULL,
	[ValueInt] [int] NULL,
	[ValueStr] [nvarchar](500) NULL,
 CONSTRAINT [PK_app_HierarchyNodeAttributeLog] PRIMARY KEY CLUSTERED 
(
	[HierarchyLogID] ASC,
	[HierarchyNodeID] ASC,
	[HierarchyNodeAttributeTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [app].[HierarchyNodeAttributeLog]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNodeAttribute_HierarchyNode_Log] FOREIGN KEY([HierarchyLogID], [HierarchyNodeID])
REFERENCES [app].[HierarchyNodeLog] ([HierarchyLogID], [HierarchyNodeID])
GO
ALTER TABLE [app].[HierarchyNodeAttributeLog] CHECK CONSTRAINT [FK_app_HierarchyNodeAttribute_HierarchyNode_Log]
GO
ALTER TABLE [app].[HierarchyNodeAttributeLog]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNodeAttribute_HierarchyNodeAttributeType_Log] FOREIGN KEY([HierarchyLogID], [HierarchyNodeAttributeTypeID])
REFERENCES [app].[HierarchyNodeAttributeTypeLog] ([HierarchyLogID], [HierarchyNodeAttributeTypeID])
GO
ALTER TABLE [app].[HierarchyNodeAttributeLog] CHECK CONSTRAINT [FK_app_HierarchyNodeAttribute_HierarchyNodeAttributeType_Log]
GO
ALTER TABLE [app].[HierarchyNodeAttributeLog]  WITH CHECK ADD  CONSTRAINT [FK_dw_HierarchyNodeAttributeLog_HierarchyLogInfo] FOREIGN KEY([HierarchyLogID])
REFERENCES [app].[HierarchyLogInfo] ([HierarchyLogID])
GO
ALTER TABLE [app].[HierarchyNodeAttributeLog] CHECK CONSTRAINT [FK_dw_HierarchyNodeAttributeLog_HierarchyLogInfo]
GO
