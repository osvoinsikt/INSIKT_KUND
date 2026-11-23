SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [app].[GetHierarchyTableName]
(
	@HierarchyID int
)
returns nvarchar(256)
as
begin
	declare @TableName nvarchar(256)
	select 
		@TableName = '[dw].' + quotename('dim_' + Name)
	from
		app.Hierarchy
	where
		HierarchyID = @HierarchyID
	return @TableName
end
GO
