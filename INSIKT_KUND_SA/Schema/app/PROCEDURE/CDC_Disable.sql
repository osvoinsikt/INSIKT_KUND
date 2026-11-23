SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [app].[CDC_Disable]
(
	@TableName sysname	
	,@CDCTableName sysname = null
	,@DropCDCObjects bit = 0
)
as

declare
	@DropScript varchar(max)	
	,@ViewName sysname	
	,@TableSchema varchar(500)
	,@CDCTableNameSchema varchar(500)

select 
	@TableSchema = coalesce(parsename(@TableName, 2),SCHEMA_NAME())
	,@TableName = parsename(@TableName, 1)
	

	
if @CDCTableName is null
	select
		@CDCTableName = @TableName + '_CDC'
		,@CDCTableNameSchema = @TableSchema
else
	select
		@CDCTableNameSchema = coalesce(parsename(@CDCTableName, 2),SCHEMA_NAME())
		,@CDCTableName = parsename(@CDCTableName, 1)
		
	
	
	


set @ViewName = @TableName + '_CDCView'

if @DropCDCObjects = 1
	begin
		-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		-- DROP TRIGGERS, VIEW AND CDC TABLE
		-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		set	@DropScript = '
		if object_id(''' + @CDCTableNameSchema + '.' + @ViewName + ''', ''v'') is not null
			drop view [' + @CDCTableNameSchema + '].[' + @ViewName + ']
	
		if object_id(''' + @TableSchema + '.CDC_ins' + @CDCTableName + ''', ''tr'') is not null
			drop trigger [' + @TableSchema + '].[CDC_ins' + @CDCTableName + ']
	
		if object_id(''' + @TableSchema + '.CDC_upd' + @CDCTableName + ''', ''tr'') is not null
			drop trigger [' + @TableSchema + '].[CDC_upd' + @CDCTableName + ']
	
		if object_id(''' + @TableSchema + '.CDC_del' + @CDCTableName + ''', ''tr'') is not null
			drop trigger [' + @TableSchema + '].[CDC_del' + @CDCTableName + ']

		if object_id(''' + @CDCTableNameSchema + '.' + @CDCTableName + ''', ''u'') is not null
			drop table [' + @CDCTableNameSchema + '].[' + @CDCTableName + ']'
	

		exec (@DropScript)
	end
else
	begin
		-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		-- DROP TRIGGERS, VIEW AND CDC TABLE
		-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		set	@DropScript = '

		if object_id(''' + @TableSchema + '.CDC_ins' + @CDCTableName + ''', ''tr'') is not null
			disable trigger [' + @TableSchema + '].[CDC_ins' + @CDCTableName + '] on ' + quotename(@TableSchema) + '.' + quotename(@TableName) + '
	
		if object_id(''' + @TableSchema + '.CDC_upd' + @CDCTableName + ''', ''tr'') is not null
			disable trigger [' + @TableSchema + '].[CDC_upd' + @CDCTableName + '] on ' + quotename(@TableSchema) + '.' + quotename(@TableName) + '
	
		if object_id(''' + @TableSchema + '.CDC_del' + @CDCTableName + ''', ''tr'') is not null
			disable trigger [' + @TableSchema + '].[CDC_del' + @CDCTableName + '] on ' + quotename(@TableSchema) + '.' + quotename(@TableName) + ''

		exec (@DropScript)
	end
GO
