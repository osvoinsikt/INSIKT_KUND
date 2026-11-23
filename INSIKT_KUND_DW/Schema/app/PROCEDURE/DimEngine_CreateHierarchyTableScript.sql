SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[DimEngine_CreateHierarchyTableScript]
(
	@SQL nvarchar(max) out
	,@HierarchyID int	
	,@TableName sysname
	,@Target int = 1	
)
as

declare @NewLine char(2)
set @NewLine = CHAR(13) + CHAR(10)

	
select @SQL = 
		'create table ' + @TableName + @NewLine +
		'(' + @NewLine

select
	@SQL = @SQL + '	' + case when c.ColumnIndex > 1 then ',' else '' end +
		quotename(c.Name) + ' ' + c.DataType + ISNULL(' default(' + c.DefaultBinding + ')', '') + @NewLine
from
	app.DimEngine_HierarchyTableColumns(@HierarchyID, @Target) c
order by 
	c.ColumnIndex


select @SQL = @SQL +
		')' + @NewLine
GO
