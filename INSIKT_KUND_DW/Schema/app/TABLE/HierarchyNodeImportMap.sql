SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[HierarchyNodeImportMap](
	[SrcHierarchyID] [int] NOT NULL,
	[SrcHierarchyNodeID] [int] NOT NULL,
	[HierarchyID] [int] NOT NULL,
	[HierarchyNodeID] [int] NOT NULL,
	[ImportDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
ALTER TABLE [app].[HierarchyNodeImportMap] ADD  DEFAULT (getutcdate()) FOR [ImportDate]
GO
