SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[CopyHierarchyNodeTree]
(
	@SourceNodeID int
	,@TargetParentID int
	,@TargetHierarchyID int = null
	,@NewNodeID int = null output
)
as
set nocount on
set @NewNodeID = null
--declare @NewNodeID int



insert into app.HierarchyNode
(	
	[HierarchyID]
	,[ParentHierarchyNodeID]
	,[SortOrder]
	,[DimensionPartTypeID]
	,[Priority]
	,[Expression]
	,[FilterExpression]
	,[SortOrderExpression]
	,[EmptyHeader]
)
select	
	[HierarchyID] = isnull(@TargetHierarchyID, s.[HierarchyID])
	,[ParentHierarchyNodeID] = @TargetParentID
	,[SortOrder] = s.[SortOrder]
	,[DimensionPartTypeID] = s.[DimensionPartTypeID]
	,[Priority] = s.[Priority]
	,[Expression] = s.[Expression]
	,[FilterExpression] = s.[FilterExpression]
	,[SortOrderExpression] = s.[SortOrderExpression]
	,[EmptyHeader] = s.[EmptyHeader]
from
	app.HierarchyNode s
where
	s.HierarchyNodeID = @SourceNodeID

set @NewNodeID = @@identity



insert into app.HierarchyNodeLanguage
(
	HierarchyNodeID
	,LanguageID
	,LangExpression
)
select
	HierarchyNodeID = @NewNodeID
	,LanguageID
	,LangExpression
from
	app.HierarchyNodeLanguage
where
	HierarchyNodeID = @SourceNodeID


insert into app.HierarchyNodeAttribute
(
	HierarchyNodeID
	,HierarchyNodeAttributeTypeID
	,ValueInt
	,ValueStr
)
select
	HierarchyNodeID = @NewNodeID
	,HierarchyNodeAttributeTypeID = tgtT.HierarchyNodeAttributeTypeID
	,ValueInt = a.ValueInt
	,ValueStr = a.ValueStr
from
	app.HierarchyNodeAttribute a
		inner join app.HierarchyNode n on
			n.HierarchyNodeID = @NewNodeID
		inner join app.HierarchyNodeAttributeType srcT on
			srcT.HierarchyNodeAttributeTypeID = a.HierarchyNodeAttributeTypeID
		inner join app.HierarchyNodeAttributeType tgtT on
			tgtT.Name = srcT.Name
			and tgtT.HierarchyID = n.HierarchyID
where
	a.HierarchyNodeID = @SourceNodeID


declare @ChildNodeID int

select @ChildNodeID = min(s.HierarchyNodeID) from app.HierarchyNode s where s.ParentHierarchyNodeID = @SourceNodeID
while @ChildNodeID is not null
	begin
		exec app.CopyHierarchyNodeTree
			@SourceNodeID =@ChildNodeID
			,@TargetParentID = @NewNodeID
			,@TargetHierarchyID = @TargetHierarchyID			
	
		select @ChildNodeID = min(s.HierarchyNodeID) from app.HierarchyNode s where s.ParentHierarchyNodeID = @SourceNodeID and s.HierarchyNodeID > @ChildNodeID
	end




return @NewNodeID
GO
