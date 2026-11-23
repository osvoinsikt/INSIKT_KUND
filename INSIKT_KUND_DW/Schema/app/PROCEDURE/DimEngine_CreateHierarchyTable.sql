SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[DimEngine_CreateHierarchyTable]
(
	@HierarchyID int	
	,@TableName sysname
	,@Target int = 1
	,@CreateConstraints bit = 1	
	,@Debug bit = 0
)
as

declare @NewLine char(2)
set @NewLine = CHAR(13) + CHAR(10)


declare
	@SQL nvarchar(max)
	
exec app.DimEngine_CreateHierarchyTableScript
	@SQL  = @SQL output
	,@HierarchyID = @HierarchyID
	,@TableName = @TableName
	,@Target = @Target

if @Debug = 0
	begin
		exec (@SQL)
		if @CreateConstraints = 1
			exec app.DimEngine_CreateHierarchyTableConstraints
					@HierarchyID = @HierarchyID
					,@TableName = @TableName
					,@Target = @Target
	end
else
	begin
		exec app.PrintMax @SQL
		if @CreateConstraints = 1
			exec app.DimEngine_CreateHierarchyTableConstraints
					@HierarchyID = @HierarchyID
					,@TableName = @TableName
					,@Target = @Target
					,@Debug = @Debug
	end
GO
