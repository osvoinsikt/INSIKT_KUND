SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [sa].[GetTableInfoFromSource_Oracle] 
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

	if @SourceSystemProviderID <> 2
		raiserror ('Invalid SourceSystemProviderID', 16, 10)
	
	if @SourceLinkedServer is null or LEN(@SourceLinkedServer) = 0
		raiserror ('Oracle source systems must have a LinkedServer specified (SA_SourceSystemID = %i)', 16, 10, @SA_SourceSystemID)
		

	if @SourceDatabase is null
		set @SourceDatabase = PARSENAME(@SourceTable, 2)

	set @SourceTable = upper(parsename(@SourceTable, 1))

	set @SourceDatabase = UPPER(@SourceDatabase)
	if @SourceDatabase is null
		set @SourceDatabase = '.'

	declare @SourceColumnList nvarchar(max) = null 
	select
		@SourceColumnList = 
			ISNULL(@SourceColumnList + ',', '')
			+ '''''' + replace(PARSENAME(upper(cols.Item), 1), '''', '''''') + '''''' 
	from
		app.Split(@SourceColumns, ',')  cols
	order by
		cols.ListPos

	set @SourceDatabase = isnull(@SourceDatabase, '') 
	declare @DynSQL nvarchar(max)

	select 
		@DynSQL =
	'
select
	col.COLUMN_NAME collate database_default as ColumnName
	,col.COLUMN_ID as ColumnOrder			
	,
	case col.data_type collate database_default
		when ''BFILE'' then ''VARBINARY(MAX)''
		when ''BLOB	'' then ''VARBINARY(MAX)''
		when ''CHAR'' then case when col.char_length = 0 then ''CHAR'' else ''CHAR'' + ''('' + CAST(col.char_length as varchar(12)) + '')'' end
		when ''CLOB'' then ''VARCHAR(MAX)''
		when ''DATE'' then ''DATETIME''
		when ''FLOAT'' then ''FLOAT''
		when ''INT'' then ''NUMERIC(38)''
		when ''INTERVAL'' then ''DATETIME''
		when ''LONG'' then ''VARCHAR(MAX)''
		when ''LONG RAW'' then ''IMAGE''
		when ''NCHAR'' then case when col.char_length = 0 then ''NCHAR'' else ''NCHAR'' + ''('' + CAST(col.char_length as varchar(12)) + '')'' end
		when ''NCLOB'' then ''NVARCHAR(MAX)''
		when ''NUMBER'' then 
			case
				when col.data_precision is null and col.data_scale is null then ''FLOAT''
				when col.data_scale is null then ''NUMERIC('' + cast(col.data_precision as varchar(12)) + '')''
				when col.data_scale > col.data_precision then ''NUMERIC('' + CAST(col.data_scale as varchar(12)) + '','' + cast(col.data_scale as varchar(12)) + '')''
				else ''NUMERIC('' + cast(col.data_precision as varchar(12)) + '','' + cast(col.data_scale as varchar(12)) + '')''
			end
		when ''NVARCHAR2'' then case when col.char_length = 0 then ''NVARCHAR'' else ''NVARCHAR('' + cast(col.char_length as varchar(12)) + '')'' end
		when ''RAW'' then case when col.data_length = 0 then ''VARBINARY'' else ''VARBINARY('' + CAST(col.data_length as varchar(12)) + '')'' end
		when ''REAL'' then ''FLOAT''
		when ''ROWID'' then ''CHAR(18)''
		when ''TIMESTAMP'' then ''DATETIME''
		when ''UROWID'' then ''CHAR(18)''
		when ''VARCHAR2'' then case when col.char_length = 0 then ''VARCHAR'' else ''VARCHAR('' + CAST(col.char_length as varchar(12)) + '')'' end
		else ''??''
	end collate database_default as SqlDataTypeExpression
			
	,cast(case when col.NULLABLE = ''Y'' then 1 else 0 end as bit) as Nullable
	,cast(null as sysname) as Collation
	,col.PK_POSITION as PrimaryOrder	
from
	openquery
	(
		'  + QUOTENAME(@SourceLinkedServer) + ', 
		''
		select 
			col.COLUMN_NAME
			,col.COLUMN_ID
			,pkCol.POSITION as PK_POSITION
			,col.DATA_TYPE			
			,col.DATA_LENGTH
			,col.DATA_PRECISION
			,col.DATA_SCALE
			,col.CHAR_LENGTH
			,col.NULLABLE
		from 
			SYS.ALL_TAB_COLUMNS col
				left join SYS.ALL_CONSTRAINTS pkI on
					pkI.OWNER = col.OWNER
					and pkI.TABLE_NAME = col.TABLE_NAME
					and pkI.CONSTRAINT_TYPE = ''''P''''
				left join SYS.ALL_CONS_COLUMNS pkCol on
					pkCol.OWNER = col.OWNER
					and pkCol.TABLE_NAME = col.TABLE_NAME
					and pkCol.COLUMN_NAME = col.COLUMN_NAME
					and pkCol.CONSTRAINT_NAME = pkI.CONSTRAINT_NAME
		where
			col.OWNER = ''''' + @SourceDatabase + '''''
			and col.TABLE_NAME = ''''' + @SourceTable + ''''' '
		+ 
		case when @SourceColumnList <> '' then '
			and 
			(
				col.COLUMN_NAME in (' + @SourceColumnList + ')
				or pkCol.POSITION is not null
			)'
		else 
				'' 
		end + '
		''
	) col
'


	if @Debug = 1 
		begin
			print '-- query ----------------------------------------------------------------------------------------------------'
			exec app.PrintMax @DynSQL
			print '-------------------------------------------------------------------------------------------------------------'
			print ''
			print ''
		end
	



	if isnull(@Debug, 0) = 0
		begin
			--if @CreateTable = 1 
			--	begin
			--		create table #CreateScript(SourceTable nvarchar(512), CreateScript nvarchar(max))
		
			--		exec ('insert into #CreateScript ' +  @DynSQL)
			--		if (select count(*) from #CreateScript) <> 1
			--			begin
			--				raiserror('Kunde inte hitta källtabell eller så blev det fel vid generering av script.', 16, 10)
			--			end
			--		else
			--			begin
			--				select @DynSQL = CreateScript from #CreateScript
			--				exec (@DynSQL)
			--				print 'Tabell skapad.'
			--			end
			--	end
			--else
			--	begin
					exec (@DynSQL)
--				end
		end

end try
begin catch
	exec app.ReThrowError
end catch
GO
