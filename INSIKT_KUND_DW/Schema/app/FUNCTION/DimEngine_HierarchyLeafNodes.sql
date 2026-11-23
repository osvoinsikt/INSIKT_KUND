SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function app.DimEngine_HierarchyLeafNodes
(
	@HierarchyID int
)
returns table
as
return
(
	select
		HierarchyNodeID = n.HierarchyNodeID
		,ParentHierarchyNodeID = n.ParentHierarchyNodeID		
	from
		app.HierarchyNode n
	where
		n.HierarchyID = @HierarchyID
		and not exists(select 1 from app.HierarchyNode child where child.ParentHierarchyNodeID = n.HierarchyNodeID)
)
GO
