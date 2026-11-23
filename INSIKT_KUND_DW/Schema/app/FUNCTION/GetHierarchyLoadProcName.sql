SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[GetHierarchyLoadProcName]
(
	@HierarchyID int
)
returns nvarchar(256)
as
begin
	declare @TableName nvarchar(256)
	select 
		@TableName = '[dbo].' + quotename('Hierarchy_dim_' + Name)
	from
		app.Hierarchy
	where
		HierarchyID = @HierarchyID
	return @TableName
end
GO
