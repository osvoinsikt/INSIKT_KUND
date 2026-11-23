SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[HierarchyNodeAttribute](
	[HierarchyNodeID] [int] NOT NULL,
	[HierarchyNodeAttributeTypeID] [int] NOT NULL,
	[ValueInt] [int] NULL,
	[ValueStr] [nvarchar](500) NULL,
 CONSTRAINT [PK_app_HierarchyNodeAttribute] PRIMARY KEY CLUSTERED 
(
	[HierarchyNodeID] ASC,
	[HierarchyNodeAttributeTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [app].[HierarchyNodeAttribute]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNodeAttribute_HierarchyNode] FOREIGN KEY([HierarchyNodeID])
REFERENCES [app].[HierarchyNode] ([HierarchyNodeID])
GO
ALTER TABLE [app].[HierarchyNodeAttribute] CHECK CONSTRAINT [FK_app_HierarchyNodeAttribute_HierarchyNode]
GO
ALTER TABLE [app].[HierarchyNodeAttribute]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNodeAttribute_HierarchyNodeAttributeType] FOREIGN KEY([HierarchyNodeAttributeTypeID])
REFERENCES [app].[HierarchyNodeAttributeType] ([HierarchyNodeAttributeTypeID])
GO
ALTER TABLE [app].[HierarchyNodeAttribute] CHECK CONSTRAINT [FK_app_HierarchyNodeAttribute_HierarchyNodeAttributeType]
GO
