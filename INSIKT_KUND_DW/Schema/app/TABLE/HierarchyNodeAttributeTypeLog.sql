SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[HierarchyNodeAttributeTypeLog](
	[HierarchyLogID] [int] NOT NULL,
	[HierarchyNodeAttributeTypeID] [int] NOT NULL,
	[HierarchyID] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[DataTypeID] [char](4) NOT NULL,
 CONSTRAINT [PK_app_HierarchyNodeAttributeTypeLog] PRIMARY KEY CLUSTERED 
(
	[HierarchyLogID] ASC,
	[HierarchyNodeAttributeTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_app_HierarchyNodeAttributeType_HierarchyName_Log] UNIQUE NONCLUSTERED 
(
	[HierarchyLogID] ASC,
	[HierarchyID] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [app].[HierarchyNodeAttributeTypeLog]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNodeAttributeType_DataType_Log] FOREIGN KEY([DataTypeID])
REFERENCES [app].[DataType] ([DataTypeID])
GO
ALTER TABLE [app].[HierarchyNodeAttributeTypeLog] CHECK CONSTRAINT [FK_app_HierarchyNodeAttributeType_DataType_Log]
GO
ALTER TABLE [app].[HierarchyNodeAttributeTypeLog]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNodeAttributeType_Hierarchy_Log] FOREIGN KEY([HierarchyLogID], [HierarchyID])
REFERENCES [app].[HierarchyLog] ([HierarchyLogID], [HierarchyID])
GO
ALTER TABLE [app].[HierarchyNodeAttributeTypeLog] CHECK CONSTRAINT [FK_app_HierarchyNodeAttributeType_Hierarchy_Log]
GO
ALTER TABLE [app].[HierarchyNodeAttributeTypeLog]  WITH CHECK ADD  CONSTRAINT [FK_dw_HierarchyNodeAttributeTypeLog_HierarchyLogInfo] FOREIGN KEY([HierarchyLogID])
REFERENCES [app].[HierarchyLogInfo] ([HierarchyLogID])
GO
ALTER TABLE [app].[HierarchyNodeAttributeTypeLog] CHECK CONSTRAINT [FK_dw_HierarchyNodeAttributeTypeLog_HierarchyLogInfo]
GO
