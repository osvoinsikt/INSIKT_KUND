SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [app].[CDC_Enable]
(
	@TableName sysname
	,@CDCTableName sysname = null
	,@AllRowsToState int = null
	,@GenerateCDCView bit = 0
)
as

declare
	 @CreateScript varchar(max)
	,@DropScript varchar(max)
	,@TriggerName sysname
	,@ViewName sysname
	,@PrimaryKeyColumnList varchar(4000)	
	,@CDCJoin varchar(2000)
	,@CDCJoinList varchar(4000)
	,@ViewColumnsList varchar(max)
	,@TableSchema varchar(500)
	,@CDCTableNameSchema varchar(500)
begin try
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

if len(@CDCTableName) > 128 raiserror('CDC Table Name is too long (%s). Max 128 characters allowed.', 16, 10, @CDCTableName)


if object_id(@TableSchema + '.' + @TableName, 'u') is null
	raiserror ('Table %s.%s does not exist', 16, 10, @TableSchema, @TableName)


declare 
	@InsTriggerName varchar(500)
	,@DelTriggerName varchar(500)
	,@UpdTriggerName varchar(500)
	,@TmpObjectID int
	,@TmpObjectFQN varchar(1024)
	,@TmpObjectType varchar(10)

select
	@InsTriggerName = 'CDC_ins' + @CDCTableName
	,@DelTriggerName = 'CDC_del' + @CDCTableName
	,@UpdTriggerName = 'CDC_upd' + @CDCTableName


if len(@InsTriggerName) > 128 raiserror('Insert trigger name is too long (%s). Max 128 characters allowed.', 16, 10, @InsTriggerName)
if len(@DelTriggerName) > 128 raiserror('Delete trigger name is too long (%s). Max 128 characters allowed.', 16, 10, @DelTriggerName)
if len(@UpdTriggerName) > 128 raiserror('Update trigger name is too long (%s). Max 128 characters allowed.', 16, 10, @UpdTriggerName)
	
select
	ID = cast(row_number() over (order by ObjectFQN, ObjectType) as int)
	,o.*
into #Objects
from
(
	select 
		ObjectFQN = quotename(@TableSchema) + '.' + quotename(@InsTriggerName)		
		,ObjectType = 'TR'		
	union select 
		ObjectFQN = quotename(@TableSchema) + '.' + quotename(@DelTriggerName)
		,ObjectType = 'TR'		
	union select 
		ObjectFQN = quotename(@TableSchema) + '.' + quotename(@UpdTriggerName)
		,ObjectType = 'TR'
	union select 
		ObjectFQN = quotename(@CDCTableNameSchema) + '.' + quotename(@CDCTableName)
		,ObjectType = 'U'
) o


declare 
	@AllExists bit = 1
	,@EnableAllTriggersScript nvarchar(max)

select @TmpObjectID = min(ID) from #Objects
while @TmpObjectID is not null
	begin
		select
			@TmpObjectFQN = ObjectFQN
			,@TmpObjectType = ObjectType
		from
			#Objects
		where
			ID = @TmpObjectID

		if object_id(@TmpObjectFQN, @TmpObjectType) is null
		begin
			--Missing
			set @AllExists = 0
		end

		if @TmpObjectType = 'TR'
			set @EnableAllTriggersScript =  isnull(@EnableAllTriggersScript,'')
				+ 'enable trigger ' + @TmpObjectFQN + ' on ' + quotename(@TableSchema) + '.' + quotename(@TableName) + '; '

		select @TmpObjectID = min(ID) from #Objects where ID > @TmpObjectID
	end
 

if @AllExists = 1
	begin		
		exec (@EnableAllTriggersScript)		
	end
else
	begin
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- COLLECT COLUMN INFORMATION
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
select
	@PrimaryKeyColumnList = coalesce(@PrimaryKeyColumnList + ', ', '') + '[' + c.name + ']'
	,@CDCJoinList = coalesce(@CDCJoinList + ' and ', '') + 'i.[' + c.Name + '] = cdc.[' + c.name + ']'
from
	sys.indexes i
		inner join sys.index_columns ic on
			ic.index_id = i.index_id
			and ic.object_id = i.object_id
			and ic.is_included_column = 0
		inner join sys.columns c on
			c.object_id = i.object_id
			and c.column_id = ic.column_id
where
	i.object_id = object_id(@TableSchema + '.' + @TableName)
	and i.is_primary_key = 1
order by
	ic.key_ordinal
	
	
	
	
select	
	@ViewColumnsList = 
		coalesce(@ViewColumnsList + ', ', '') +
		case 
			when ic.column_id is null then
				'i.[' + c.Name + ']'
			else
				'cdc.[' + c.Name + ']'
		end
from
	sys.columns c
		inner join sys.indexes i on
			c.object_id = i.object_id
			and i.is_primary_key = 1
		left join sys.index_columns ic on
			ic.index_id = i.index_id
			and ic.object_id = i.object_id
			and ic.is_included_column = 0
			and c.column_id = ic.column_id
where
	c.object_id = object_id(@TableSchema + '.' + @TableName)
order by
	c.column_id
	
	


-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- MAKE SURE CDC-TABLE EXISTS
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set	@CreateScript = '
if object_id(''' + @CDCTableNameSchema + '.' + @CDCTableName + ''', ''U'') is null
	begin
		create table [' + @CDCTableNameSchema + '].[' + @CDCTableName + ']
		('
		
select @CreateScript = @CreateScript + '
			[' + c.name + '] ' +
	t.name + 
		case 
			when t.name like '%char' or t.name like '%text' then
				'(' + cast(case when t.name in ('nvarchar', 'nchar', 'ntext') then c.max_length / 2 else c.max_length end as varchar(12)) + ')'
			when t.user_type_id in (106, 108) then -- numeric and decimal
				'(' + cast(c.precision as varchar(12)) + ',' + cast(c.scale as varchar(12)) + ')'
			else
				''
		end +
		case
			when c.is_nullable = 1 then
				' null'
			else
				' not null'
		end +
		','
from
	sys.indexes i
		inner join sys.index_columns ic on
			ic.index_id = i.index_id
			and ic.object_id = i.object_id
			and ic.is_included_column = 0
		inner join sys.columns c on
			c.object_id = i.object_id
			and c.column_id = ic.column_id
		inner join sys.types t on t.user_type_id = c.user_type_id
where
	i.object_id = object_id(@TableSchema + '.' + @TableName)
	and i.is_primary_key = 1
order by
	ic.key_ordinal


		
set @CreateScript = @CreateScript + '
			CDC_ActionID smallint not null,
			constraint [PK_' + @CDCTableName + '] primary key clustered
			(
				' + @PrimaryKeyColumnList + '
			)
		)
'
set @CreateScript = @CreateScript + '
		alter table [' + @CDCTableNameSchema + '].[' + @CDCTableName + '] add constraint
			[FK_' + @CDCTableName + '_CDC_Action] foreign key
			(
				CDC_ActionID
			) references app.CDC_Action
			(
				ID
			)
	end
'
--print @CreateScript
exec (@CreateScript)

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- CREATE VIEW
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if @GenerateCDCView = 1
	begin
		exec ('
		if object_id(''' + @CDCTableNameSchema + '.' + @ViewName + ''', ''v'') is not null
			drop view ['+ @CDCTableNameSchema + '].[' + @ViewName + ']
		')

		exec ('
		create view [' + @CDCTableNameSchema + '].[' + @ViewName + '] as
		select
			' + @ViewColumnsList + '
			,cdc.CDC_ActionID
		from
			[' + @CDCTableNameSchema + '].[' + @CDCTableName + '] cdc
				left join [' + @TableSchema + '].[' + @TableName + '] i on
					' + @CDCJoinList + '
		')
	end

declare @DisableTriggerScript nvarchar(max) = 
	case when cast(parsename(cast(SERVERPROPERTY('ProductVersion') as varchar(50)), 4) as int) >= 13 then '
	/*
	--
	-- Disable trigger in current session
	--
	EXEC sys.sp_set_session_context 
		@key = N''Disable:' + parsename(@CDCTableName, 1) +  ''', 
		@value = 1; -- 1 = Disable; NULL/0 = Enabled
	*/
	if SESSION_CONTEXT(N''Disable:' + parsename(@CDCTableName, 1) +  ''') = 1
		return;'
	else 
		''
	end
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- INSERT TRIGGER
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set @TriggerName = @InsTriggerName

set	@DropScript = '
if object_id(''' + @TableSchema + '.' + @TriggerName + ''', ''TR'') is not null
	drop trigger [' + @TableSchema + '].[' + @TriggerName + ']'

set @CreateScript = '
create trigger [' + @TableSchema + '].[' + @TriggerName + ']
on [' + @TableSchema + '].[' + @TableName + ']
after insert
AS 
begin	
	set nocount on;
	' + @DisableTriggerScript + '

	-- Convert deleted recordes to updateD records.
	update cdc set
		CDC_ActionID = 2
	from
		inserted i
			inner join [' + @CDCTableNameSchema + '].[' + @CDCTableName + '] cdc on
				' + @CDCJoinList + '
				and cdc.CDC_ActionID = 3
	

	-- Add new recordes
	insert into [' + @CDCTableNameSchema + '].[' + @CDCTableName + '](' + @PrimaryKeyColumnList + ', CDC_ActionID)
	select ' + @PrimaryKeyColumnList + ', 1 from inserted i where not exists(select 1 from [' + @CDCTableNameSchema + '].[' + @CDCTableName + '] cdc where ' + @CDCJoinList + ')
end
'

exec (@DropScript)
exec (@CreateScript)





-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- UPDATE TRIGGER
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set @TriggerName = @UpdTriggerName

set	@DropScript = '
if object_id(''' + @TableSchema + '.' + @TriggerName + ''', ''TR'') is not null
	drop trigger [' + @TableSchema + '].[' +@TriggerName + ']'

set @CreateScript = '
create trigger [' + @TableSchema + '].[' + @TriggerName + ']
on [' + @TableSchema + '].[' + @TableName + ']
after update
AS 
begin	
	set nocount on;
	' + @DisableTriggerScript + '

	-- Add new recordes
	insert into [' + @CDCTableNameSchema + '].[' + @CDCTableName + '](' + @PrimaryKeyColumnList + ', CDC_ActionID)
	select ' + @PrimaryKeyColumnList + ', 2 from inserted i where NOT EXISTS (select 1 from [' + @CDCTableNameSchema + '].[' + @CDCTableName + '] cdc where ' + @CDCJoinList + ')
end
'
exec (@DropScript)
exec (@CreateScript)

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- DELETE TRIGGER
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set @TriggerName = @DelTriggerName

set	@DropScript = '
if object_id(''' + @TableSchema + '.' + @TriggerName + ''', ''TR'') is not null
	drop trigger [' + @TableSchema + '].[' +@TriggerName + ']'

set @CreateScript = '
create trigger [' + @TableSchema + '].[' + @TriggerName + ']
on [' + @TableSchema + '].[' + @TableName + '] 
after delete
as 
begin	
	set nocount on;
	' + @DisableTriggerScript + '

	-- Convert updateD recordes to deleted records.
	update cdc set
		CDC_ActionID = 3
	from
		deleted i
			inner join [' + @CDCTableNameSchema + '].[' + @CDCTableName + '] cdc on
				' + @CDCJoinList + '
	where
		cdc.CDC_ActionID = 2
	

	-- Add new recordes
	insert into [' + @CDCTableNameSchema + '].[' + @CDCTableName + '](' + @PrimaryKeyColumnList + ', CDC_ActionID)
	select ' + @PrimaryKeyColumnList + ', 3 from deleted i where NOT EXISTS (select 1 from [' + @CDCTableNameSchema + '].[' + @CDCTableName + '] cdc where ' + @CDCJoinList + ')

	-- Remove recordes that had status inserted
	DELETE from cdc
	from
		deleted i
			inner join [' + @CDCTableNameSchema + '].[' + @CDCTableName + '] cdc on
				' + @CDCJoinList + '
	where
		cdc.CDC_ActionID = 1
end
'
exec (@DropScript)
exec (@CreateScript)

end

declare @sql varchar(max)
if @AllRowsToState is not null
	begin		
		begin tran
		exec ('delete from [' + @CDCTableNameSchema + '].[' + @CDCTableName + ']')
		select @sql = 
			'insert into [' + @CDCTableNameSchema + '].[' + @CDCTableName + '](' + @PrimaryKeyColumnList + ', CDC_ActionID)' +
			'select ' + @PrimaryKeyColumnList + ', ' + cast(@AllRowsToState as varchar(12)) + ' from [' + @TableSchema + '].[' + @TableName + ']'
		exec (@sql)
		commit tran
	end
end try
begin catch
	throw;
end catch
GO
