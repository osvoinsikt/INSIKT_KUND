SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function app.DimEngine_HierarchyLeafNodeTable
(
	@HierarchyID int
)
returns table
as
return
(
	with
	HierarchyNodeTable as
	(
		select
			LeafHierarchyNodeID = n.HierarchyNodeID
			,HierarchyNodeID = n.HierarchyNodeID
			,ParentHierarchyNodeID = n.ParentHierarchyNodeID
			,LeafDistance = 0
		from
			app.DimEngine_HierarchyLeafNodes(@HierarchyID) n
		union all
		select
			LeafHierarchyNodeID = pn.LeafHierarchyNodeID
			,HierarchyNodeID = n.HierarchyNodeID
			,ParentHierarchyNodeID = n.ParentHierarchyNodeID
			,LeafDistance = pn.LeafDistance + 1
		from
			app.HierarchyNode n
				inner join HierarchyNodeTable pn on
					pn.ParentHierarchyNodeID = n.HierarchyNodeID
	)
	select
		LeafHierarchyNodeID
		,HierarchyNodeID
		,ParentHierarchyNodeID
		,LeafDistance
	from
		HierarchyNodeTable
)
GO
