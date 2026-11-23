SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure app.ShowHierarchyConfiguration
(
	@HierarchyID int
) as	
;with TreeNode as
(	
	select
		n.[HierarchyID]
		,n.HierarchyNodeID
		,n.ParentHierarchyNodeID
		,n.DimensionPartTypeID
		,[Level] = 1
		,[Name] = n.Expression
		,n.[FilterExpression]
		,n.[Priority]
		,SortOrder = n.SortOrder
		,SortOrderExpression = n.SortOrderExpression		
		,TreePath = cast(n.Expression as varchar(8000))
		,TreeOrder = cast(right('000000000000' + cast(row_number() over(order by n.SortOrder) as varchar(12)), 12) as varchar(8000))
		
	from
		app.HierarchyNode n			
	where
		n.ParentHierarchyNodeID is null
		and n.HierarchyID = @HierarchyID
	
	union all
	
	select
		n.[HierarchyID]
		,n.HierarchyNodeID
		,n.ParentHierarchyNodeID
		,n.DimensionPartTypeID
		,p.[Level] + 1
		,[Name] = n.Expression
		,n.[FilterExpression]
		,n.[Priority]
		,SortOrder = n.SortOrder
		,SortOrderExpression = n.SortOrderExpression
		,TreePath = cast(p.TreePath + ' / ' + n.Expression as varchar(8000))
		,TreeOrder = cast(p.TreeOrder + right('000000000000' + cast(row_number() over(partition by n.ParentHierarchyNodeID order by n.SortOrder) as varchar(12)), 12) as varchar(8000))
		
	from
		TreeNode p
			inner join app.HierarchyNode n on
				n.ParentHierarchyNodeID = p.HierarchyNodeID			
)
select
	n.HierarchyID
	,HierarchyNodeID = n.HierarchyNodeID	
	,n.ParentHierarchyNodeID
	,Node = 
		case
			when n.DimensionPartTypeID is null and left(n.Name, 1) = '''' and right(n.Name, 1) = '''' and LEN(n.Name) > 1 then
				substring(n.Name, 2, LEN(n.Name) - 2)
			else				
				'<' + t.Name +'>'
		end
	,TreeNode = replicate('     ',n.[Level] - 1) + 
		case
			when n.DimensionPartTypeID is null and left(n.Name, 1) = '''' and right(n.Name, 1) = '''' and LEN(n.Name) > 1 then
				substring(n.Name, 2, LEN(n.Name) - 2)
			else				
				'<' + t.Name +'>'
		end
	,Priority = n.[Priority]	
	,Filter = coalesce(n.FilterExpression, '')
	,SortOrder = n.SortOrder
	,SortOrderExpression = n.SortOrderExpression


	,TreeLevel = n.[Level]
	,TreePath = '/ ' + n.TreePath	
from
	TreeNode n
		left join app.DimensionPartType t on
			t.DimensionPartTypeID = n.DimensionPartTypeID
order by
	n.TreeOrder
GO
