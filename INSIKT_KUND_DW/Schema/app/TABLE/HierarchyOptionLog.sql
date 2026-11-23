SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[HierarchyOptionLog](
	[HierarchyLogID] [int] NOT NULL,
	[ID] [int] NOT NULL,
	[HierarchyID] [int] NOT NULL,
	[HierarchyOptionTypeID] [char](4) NOT NULL,
	[ValueInt] [int] NULL,
	[ValueStr] [nvarchar](500) NULL,
 CONSTRAINT [PK_app_HierarchyOptionLog] PRIMARY KEY CLUSTERED 
(
	[HierarchyLogID] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [app].[HierarchyOptionLog]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyOption_app_Hierarchy_Log] FOREIGN KEY([HierarchyLogID], [HierarchyID])
REFERENCES [app].[HierarchyLog] ([HierarchyLogID], [HierarchyID])
GO
ALTER TABLE [app].[HierarchyOptionLog] CHECK CONSTRAINT [FK_app_HierarchyOption_app_Hierarchy_Log]
GO
ALTER TABLE [app].[HierarchyOptionLog]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyOption_app_HierarchyOption_Typ_Log] FOREIGN KEY([HierarchyOptionTypeID])
REFERENCES [app].[HierarchyOptionType] ([HierarchyOptionTypeID])
GO
ALTER TABLE [app].[HierarchyOptionLog] CHECK CONSTRAINT [FK_app_HierarchyOption_app_HierarchyOption_Typ_Log]
GO
ALTER TABLE [app].[HierarchyOptionLog]  WITH CHECK ADD  CONSTRAINT [FK_dw_HierarchyOptionLog_HierarchyLogInfo] FOREIGN KEY([HierarchyLogID])
REFERENCES [app].[HierarchyLogInfo] ([HierarchyLogID])
GO
ALTER TABLE [app].[HierarchyOptionLog] CHECK CONSTRAINT [FK_dw_HierarchyOptionLog_HierarchyLogInfo]
GO
