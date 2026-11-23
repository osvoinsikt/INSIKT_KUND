SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[CDC_Fact_Enable] 
(
	@SourceFactTable nvarchar(512)
	,@UpdateTrigger bit = null
	,@TargetFactTable nvarchar(512) = null
	,@Debug bit = 0
)
as

set nocount on
begin try
--declare 
--	@SourceFactTable nvarchar(512) = 'dw.fact_ProfitAndLoss_R4'
--	,@TargetFactTable nvarchar(512) = 'dw.fact_ProfitAndLoss_R4_FactCDC'

--	,@UpdateTrigger bit = 0

declare @ObjectName nvarchar(512)
if @TargetFactTable is null
	begin
		set @ObjectName = parsename(@SourceFactTable, 1) + '_FactCDC';
		if len(@ObjectName) > 128 raiserror('Target table name is too long (%s). Max 128 characters allowed.', 16, 10, @ObjectName)
		set @TargetFactTable = 
			isnull(quotename(parsename(@SourceFactTable, 2)) + '.', '') 
			+ quotename(@ObjectName)
	end

declare @TriggerName nvarchar(512)
select @TriggerName = 'CDC_' + parsename(@SourceFactTable, 1) + '_to_' + parsename(@TargetFactTable, 1)
if len(@TriggerName) > 128 set @TriggerName = left(@TriggerName, 120) + convert(nvarchar(8), cast(checksum(@TriggerName) as binary(4)), 2)


select
	tab.object_id
	,c.column_id
	,c.name
	,is_measure = 
		case when
			c.name not in
			(	
				select parsename(IDColumnName, 1)From app.DImensionPartType
			)
			and c.system_type_id in
			(
				59 -- real
				,60 -- money
				,62 -- float
				,106 -- decimal
				,108 -- numeric
				,122 -- smallmoney
			)
			then 1
			else 0
			end

	,is_primary_key = case when pkCol.column_id is not null then 1 else 0 end
	,c.system_type_id
	,c.user_type_id
	,c.max_length
	,c.precision
	,c.scale
	,c.collation_name
	,c.is_nullable
	,c.is_computed
	,computed_def = cc.definition
	,data_type  = ISNULL(TYPE_NAME(c.system_type_id), t.name)
	,character_maximum_length = COLUMNPROPERTY(c.object_id, c.name, 'charmaxlen')
	,character_octet_length = COLUMNPROPERTY(c.object_id, c.name, 'octetmaxlen')
	,numeric_precision = 
		convert(tinyint,CASE 				-- int/decimal/numeric/real/float/money
				WHEN c.system_type_id IN (48, 52, 56, 59, 60, 62, 106, 108, 122, 127) THEN c.precision END)
	,numeric_precision_radix = convert(smallint, CASE	-- int/money/decimal/numeric
		WHEN c.system_type_id IN (48, 52, 56, 60, 106, 108, 122, 127) THEN 10
		WHEN c.system_type_id IN (59, 62) THEN 2 END)	-- real/float
	,numeric_scale = convert(int, CASE	-- datetime/smalldatetime
		WHEN c.system_type_id IN (40, 41, 42, 43, 58, 61) THEN NULL
		ELSE ODBCSCALE(c.system_type_id, c.scale) END)
	,datetime_precision = convert(smallint, CASE -- datetime/smalldatetime
		WHEN c.system_type_id IN (40, 41, 42, 43, 58, 61) THEN ODBCSCALE(c.system_type_id, c.scale) END)
--	,collation_name = c.collation_name
	
into #SourceColumns	
from
	sys.tables tab
		inner join sys.columns c on
			c.object_id = tab.object_id		
		inner join sys.types t on
			t.user_type_id = c.user_type_id
		left join sys.indexes pkI on
			pkI.object_id = tab.object_id
			and pkI.is_primary_key = 1
		left join sys.index_columns pkCol on
			pkCol.object_id = tab.object_id
			and pkCol.index_id = pkI.index_id
			and pkCol.column_id = c.column_id
		left join sys.computed_columns cc on
			cc.object_id = tab.object_id
			and cc.column_id = c.column_id

where
	tab.object_id = object_id(@SourceFactTable)

	and 
	(
		object_id(@TargetFactTable) is null
		or
		c.name in
		(
			select
				targetC.name
			from
				sys.columns targetC 
			where
				targetC.object_id = object_id(@TargetFactTable)
		)
	)

	
if object_id(@TargetFactTable) is null
	begin
		declare @CreateTab nvarchar(max)
		select @CreateTab = 
		'create table ' + @TargetFactTable + '
(
	[CDC_ID] int not null identity(1,1) primary key' +	
			(
				select 
					col_def = '
	,' +
						quotename(c.name) + ' ' +
						case
							when c.computed_def is not null then
								'as ' + c.computed_def
							else
								c.data_type + 
								case c.data_type
									when 'sql_variant' then ''
									when 'text' then ''
									when 'ntext' then ''
									when 'xml' then ''
									when 'decimal' then '(' + cast(numeric_precision as varchar) + ', ' + cast(numeric_scale as varchar) + ')'
									when 'numeric' then '(' + cast(numeric_precision as varchar) + ', ' + cast(numeric_scale as varchar) + ')'
									else coalesce('('+case when character_maximum_length = -1 then 'MAX' else cast(character_maximum_length as varchar) end +')','') 
								end
							+
							case c.is_nullable
								when 1 then ' null'
								else ' not null'
							end
						end
				from
					#SourceColumns c
				order by
					c.column_id
				for xml path, type).value(N'.[1]', N'nvarchar(max)')
				+
				'
)'
		print '----------------------------------------------------------------------------------------------------'
		print '-- Creating fact CDC table: ' + @TargetFactTable
		print '----------------------------------------------------------------------------------------------------'
		if @CreateTab is null
			raiserror('Unable to create table, no column defintions found. Verify that source fact-table %s exists.', 16, 10, @SourceFactTable)

		if (@Debug = 1)
			exec app.PrintMax @CreateTab
		else
			exec (@CreateTab)

end

		declare @CreateTrigger nvarchar(max)
		select @CreateTrigger = 
		'create trigger ' + quotename(@TriggerName) + ' on ' + @SourceFactTable + ' for 
	insert, update, delete as
begin
	set nocount on'
	+ 
	case when cast(parsename(cast(SERVERPROPERTY('ProductVersion') as varchar(50)), 4) as int) >= 13 then '
	/*
	--
	-- Disbale trigger in current session
	--
	EXEC sys.sp_set_session_context 
		@key = N''Disable:' + parsename(@TargetFactTable, 1) +  ''', 
		@value = 1; -- 1 = Disable; NULL/0 = Enabled
	*/
	if SESSION_CONTEXT(N''Disable:' + parsename(@TargetFactTable, 1) +  ''') = 1
		return;'
	else 
		''
	end 	
	+ '
	
	
	
	insert into ' + @TargetFactTable + '
	(
		'
		+
		(
			select
				case when row_number() over (order by c.column_id) > 1 then '
		,' else '' end +
				quotename(c.name)
			from
				#SourceColumns c
			where
				c.is_computed = 0
			order by
				c.column_id
			for xml path, type
		).value(N'.[1]', N'nvarchar(max)')
		+
		'
	)
	--
	-- Turn deleted/updated rows
	--
	select
		'
		+
		(
			select
				case when row_number() over (order by c.column_id) > 1 then '
		,' else '' end +
				quotename(c.name) + ' = ' 
					+ case when c.is_measure = 1 then '-' else '' end -- Vänd alla measures
					+ 'f.' + quotename(c.name)
			from
				#SourceColumns c
			where
				c.is_computed = 0
			order by
				c.column_id
			for xml path, type
		).value(N'.[1]', N'nvarchar(max)')
		+
		'
	from
		deleted f			
	union all
	--
	-- Add new value for inserted/updated rows
	--
	select
		'
		+
		(
			select
				case when row_number() over (order by c.column_id) > 1 then '
		,' else '' end +
				quotename(c.name) + ' = f.' + quotename(c.name)
			from
				#SourceColumns c
			where
				c.is_computed = 0
			order by
				c.column_id
			for xml path, type
		).value(N'.[1]', N'nvarchar(max)')
		+
		'
	from
		inserted f		
	
end'

declare @TriggerExists bit = 0
declare @TriggerFQN nvarchar(512)
select @TriggerFQN = isnull(quotename(parsename(@SourceFactTable, 2)) + '.', '') + QUOTENAME(@TriggerName)
if exists
(	
	select
		*
	from
		sys.triggers t
	where
		parent_id = object_id(@SourceFactTable)
		and t.name = @TriggerName
)
	set @TriggerExists = 1

if @TriggerExists = 0 or @UpdateTrigger = 1
	begin
		--
		-- Creating trigger
		--
		print '----------------------------------------------------------------------------------------------------'
		if @TriggerExists = 1
			print '-- Updateing trigger: ' + @TriggerName
		else
			print '-- Creating trigger: ' + @TriggerName
		print '----------------------------------------------------------------------------------------------------'
		

		if (@Debug = 1)
			begin
				exec app.PrintMax @CreateTrigger
			end
		else
			begin
				if @TriggerExists = 1 exec ('drop trigger ' + @TriggerFQN)
				exec (@CreateTrigger)
			end

	end
else
	begin
		print '----------------------------------------------------------------------------------------------------'
		print '-- Trigger already exists: ' + @TriggerFQN 
		print '-- Use the following script to update it if needed'
		print '----------------------------------------------------------------------------------------------------'
		print 'go'
		print 'drop trigger ' + @TriggerFQN
		print 'go'
		exec app.PrintMax @CreateTrigger
		print 'go'
		print '----------------------------------------------------------------------------------------------------'
		
	end


drop table #SourceColumns

end try
begin catch
	throw;
end catch
GO
