SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [sa].[GetTableInfoFromSource_SQLServer] 
(
	@SourceTable nvarchar(256) -- Name and schema of source table.
	,@SourceColumns nvarchar(max) = null -- Null for all columns och comma separated list with columns to load (PK column are always loaded regardless if they are in the list or not).
	,@SA_SourceSystemID int = null -- SA_SourceSystem to use as source when reading source datatype and columns. When NULL the first with @TargetSchema
	
	
	,@Debug bit = 0
)
as
set nocount on
begin try
	declare
		@SourceLinkedServer nvarchar(256) = null	
		,@SourceDatabase nvarchar(256) = null
		,@SourceSystemProviderID int

	declare @NewLine nchar(2)
	set @NewLine = nchar(13) + nchar(10)

	if @SA_SourceSystemID is not null
		begin
			select
				--@TargetSchema = s.TargetSchema
				--,
				@SourceLinkedServer = s.LinkedServer
				,@SourceDatabase = s.[Database]
				,@SourceSystemProviderID = @SourceSystemProviderID
			from
				sa.base_SourceSystem s
			where
				s.SA_SourceSystemID = @SA_SourceSystemID
			if @@ROWCOUNT = 0
				raiserror('Unable to find SA_SourceSystemID %i.', 16, 10, @SA_SourceSystemID)
		end
	else
		raiserror ('@SA_SourceSystemID cannot be NULL', 16, 10)
		
	declare @SourceTableFQN nvarchar(512)
	set @SourceTableFQN = 
		QUOTENAME(isnull(PARSENAME(@SourceTable, 2), 'dbo')) 
		+ '.' 
		+ QUOTENAME(PARSENAME(@SourceTable, 1))

	declare @LocalServer bit = 0
	if @@SERVERNAME = @SourceLinkedServer or isnull(nullif(@SourceLinkedServer, ''), '.') = '.'
		set @LocalServer = 1


	declare @SourceColumnList nvarchar(max) = null 
	select
		@SourceColumnList = 
			ISNULL(@SourceColumnList + ',', '')
			+ '''' + replace(PARSENAME(cols.Item, 1), '''', '''''') + '''' 
	from
		app.Split(@SourceColumns, ',')  cols
	order by
		cols.ListPos

	set @SourceDatabase = isnull(@SourceDatabase + N'.', '') 
	declare @DynSQL nvarchar(max)

	select 
		@DynSQL =
	'
select
	ColumnName = col.name
	,ColumnOrder = col.column_id
	,SqlDataTypeExpression = 
		case
					when sysDataType.name = ''timestamp'' then
						''binary(8)''
					else
						quotename(sysDataType.name)
						+ case
							when sysDataType.name like ''n%char%'' then
								N''('' + cast(isnull(cast(nullif(coalesce(col.max_length, userDataType.max_length, sysDataType.max_length, 0), -1) / 2 as nvarchar(12)), N''max'') as nvarchar(12)) + N'')''
							when sysDataType.name like ''%char%'' then
								N''('' + cast(isnull(cast(nullif(coalesce(col.max_length, userDataType.max_length, sysDataType.max_length, 0), -1) as nvarchar(12)), N''max'') as nvarchar(12)) + N'')''
							when sysDataType.name in (''decimal'',''numeric'') then
								N''('' 
									+ cast(coalesce(col.precision, userDataType.precision, sysDataType.precision, '''') as nvarchar(12))
									+ '','' + cast(coalesce(col.scale, userDataType.scale, sysDataType.scale, N'''') as nvarchar(12))
								+ N'')''
							when sysDataType.name in (''float'') then					
									isnull(N''('' + cast(coalesce(col.precision, userDataType.precision, sysDataType.precision) as nvarchar(12)) + N'')'', N'''')
							when sysDataType.name like ''%binary%'' then
								N''('' 
									+ cast(isnull(cast(nullif(coalesce(col.max_length, userDataType.max_length, sysDataType.max_length, 0), -1) as nvarchar(12)), N''max'') as nvarchar(12))
								+ N'')''
							else
								N''''
							end			
					end
	,IsNullable = col.is_nullable
	,Collation = col.collation_name
	,PrimaryKeyOrder = pkCol.key_ordinal
from
	' + @SourceDatabase + 'sys.all_columns col
		inner join ' + @SourceDatabase + 'sys.types userDataType on
			userDataType.user_type_id = col.user_type_id
			and userDataType.system_type_id  = col.system_type_id
		inner join ' + @SourceDatabase + 'sys.types sysDataType on
			sysDataType.system_type_id = userDataType.system_type_id
			and sysDataType.user_type_id = userDataType.system_type_id
		left join ' + @SourceDatabase + 'sys.indexes pkI on
			pkI.is_primary_key = 1 
			and pkI.object_id = col.object_id
		left join ' + @SourceDatabase + 'sys.index_columns pkCol on
			pkCol.object_id = pkI.object_id
			and pkCol.index_id = pkI.index_id
			and pkCol.column_id = col.column_id
where
	col.object_id = object_id(''' + @SourceDatabase + @SourceTableFQN + ''')'
	+ 
	case when @SourceColumnList <> '' then '
	and 
	(
		col.name in (' + @SourceColumnList + ')
		or pkCol.object_id is not null
	)'
	else 
		'' 
	end


	if @Debug = 1 
		begin
			print '-- Remote query ---------------------------------------------------------------------------------------------'
			exec app.PrintMax @DynSQL
			print '-------------------------------------------------------------------------------------------------------------'
			print ''
			print ''
		end
	select @DynSQL = 
		case when @LocalServer = 0 then
			'select * from openquery('  + quotename(@SourceLinkedServer) + ', ''' + replace(@DynSQL, '''', '''''') + ''')'
		else
			@DynSQL
		end


	if @Debug = 1 
		begin
			print '-- Local query ---------------------------------------------------------------------------------------------'
			exec app.PrintMax @DynSQL
			print '-------------------------------------------------------------------------------------------------------------'
			print ''
			print ''
		end

	if isnull(@Debug, 0) = 0
		begin
			exec (@DynSQL)
		end

end try
begin catch
	exec app.ReThrowError
end catch
GO
