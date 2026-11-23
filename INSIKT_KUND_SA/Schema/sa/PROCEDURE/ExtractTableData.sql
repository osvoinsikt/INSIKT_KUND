SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [sa].[ExtractTableData]
(
	@SyncMethod int = null
	,@SA_SourceSystemID int
	,@SourceSystemProviderID int
	,@SourceLinkedServer sysname
	,@SourceDatabase sysname
	,@SourceTableFQN nvarchar(512)
	,@TargetTableFQN nvarchar(512)
	
	,@SourceFilter varchar(max) = null
	,@TargetFilter varchar(max) = null
	,@DynamicFilterSetterQuery varchar(max) = null

	,@ParentEventID int = null
	,@Debug bit = null
)
as
set nocount on;
--
-- Standardvariabler
--
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount


begin try
	--------------------------------------------------------------------------
	-- Start
	--------------------------------------------------------------------------	
	declare @Msg varchar(1000)
	declare @RowCnt bigint

	declare @DynSQL nvarchar(max)
	declare @DynSqlParmDefinition nvarchar(max);

	declare @CompanyCode nvarchar(max)
	select @CompanyCode = CompanyCode
	from sa.base_SourceSystem
	where SA_SourceSystemID = @SA_SourceSystemID

	-- 
	-- If provider is SQL Server and schema is missing on source table, assume DBO instead of current user default schema. 
	-- 
	if @SourceSystemProviderID = 1 and parsename(@SourceTableFQN, 2) is null 
	set @SourceTableFQN = '[dbo].' + @SourceTableFQN 


	if @TargetTableFQN is null 
		begin
			raiserror('@TargetTable är NULL', 16, 10)
			return;
		end

	declare @TargetDatabase varchar(150)
	if left(parsename(@TargetTableFQN, 1), 1) = '#' 
		set @TargetDatabase = 'tempdb'
			
	set @SourceDatabase = 
		quotename
		(
			parsename(@SourceDatabase, 1)
			,case when @SourceSystemProviderID = 1 then '[' else '"' end -- Always ANSI IDENTIFIER for other providers than SQL Server
		)

	--select @TargetTable, @SourceTable


	
	

	declare @LocalServer bit = 0
	if @@SERVERNAME = @SourceLinkedServer or isnull(nullif(@SourceLinkedServer, ''), '.') = '.'
	set @LocalServer = 1
	
	create table #ColumnsInTarget
	(
		ColumnName sysname primary key
		,Collation nvarchar(512)
	)
	if @TargetDatabase = 'tempdb'
		insert into #ColumnsInTarget
		(
			ColumnName
			,Collation
		)
		select
			name
			,collation_name
		from
			tempdb.sys.columns c
		where
			c.object_id = object_id('tempdb..' + @TargetTableFQN)			
			
	else
		insert into #ColumnsInTarget
		(
			ColumnName
			,Collation
		)
		select
			name
			,collation_name
		from
			sys.columns c
		where
			c.object_id = object_id(@TargetTableFQN)


	declare @ColumnsInTargetList nvarchar(max)

	select 
		@ColumnsInTargetList = ISNULL(@ColumnsInTargetList + ',', '') 
			+ ColumnName
	from
		#ColumnsInTarget

	create table #SourceColumns
	(
		ColumnName nvarchar(128)  collate database_default not null
		,ColumnOrder int not null
		,SqlDataTypeExpression varchar(512) collate database_default not null
		,Nullable bit not null
		,Collation varchar(512) collate database_default
		,PrimaryKeyOrder int
	)
	exec [sa].[GetSourceTableInfo]
		@SourceTable = @SourceTableFQN
		,@SourceColumns = @ColumnsInTargetList -- Only source columns that exists in target table
		,@SA_SourceSystemID = @SA_SourceSystemID

	
	
	--select
	--	@SourceTableFQN
	--	,@ColumnsInTargetList
	--	,@SA_SourceSystemID

	declare @SourceSelectList varchar(max)
	declare @TargetInsertList varchar(max)
	declare @TargetSelectList varchar(max)


	
	;with ColumnData as
	(
		select
			InsertList = quotename(targetCol.ColumnName)
			,SelectList =
				quotename(targetCol.ColumnName) + case when ISNULL(srcCol.Collation, '') <> ISNULL(targetCol.Collation, '') then ' collate database_default ' else '' end
			,SourceList = 
				quotename
				(
					srcCol.ColumnName
					,case when @SourceSystemProviderID = 1 then '[' else '"' end -- Always ANSI IDENTIFIER for other providers than SQL Server
				)
		from
			#SourceColumns srcCol
				inner join #ColumnsInTarget targetCol on
					targetCol.ColumnName = srcCol.ColumnName
			
		union
		select
			InsertList = quotename(targetCol.ColumnName)
			,SelectList = quotename(targetCol.ColumnName) + ' = ' + cast(@SA_SourceSystemID as varchar(12))
			,SourceList = null
		from	
			#ColumnsInTarget targetCol	
		where			
			targetCol.ColumnName  = 'SA_SourceSystemID'
	)
	select
		@TargetSelectList = isnull(@TargetSelectList + ',', '') + SelectList	
		,@TargetInsertList= isnull(@TargetInsertList + ',', '') + InsertList
		,@SourceSelectList = isnull(isnull(@SourceSelectList + ',', '') + SourceList, @SourceSelectList)
	from
		ColumnData
		
	--select
	--	*
	--from
	--	#ColumnsInTarget

	--select
	--	*
	--from
	--	#SourceColumns

	--select
	--	@TargetSelectList
	--	,@TargetInsertList
	--	,@TargetInsertList
		
	
	--declare @DynFilterOut varchar(max)
	
	if len(@DynamicFilterSetterQuery) > 0
		begin
			select @DynSql = N'' 
				+
				replace
				(
					replace
					(
						replace
						(
							replace
							(
								replace
								(
									replace
									(
										@DynamicFilterSetterQuery 
										,'¤CompanyCode¤'
										,isnull(@CompanyCode, '')
									) 
									,'¤TargetTable¤'
									,isnull(@TargetTableFQN, '')
								)
								,'¤SourceTable¤'
								,isnull(@SourceTableFQN, '')
							)
							,'¤TargetDatabase¤'
							,isnull(@TargetDatabase, '')
						)
						,'¤SourceDatabase¤'
						,isnull(@SourceDatabase, '')
					)
					,'¤SourceLinkedServer¤'
					,isnull(@SourceLinkedServer, '')
				)
				+ ';'

			SET @DynSqlParmDefinition = N'
				@SA_SourceSystemID int
				,@SourceTable varchar(150)
				,@SourceFilter varchar(max) OUTPUT
				,@TargetFilter varchar(max) OUTPUT
				,@TargetTable varchar(150)
				,@SourceLinkedServer sysname
				,@SourceDatabase sysname'

			EXECUTE sp_executesql @DynSql, @DynSqlParmDefinition,
				@SA_SourceSystemID
				,@SourceTableFQN
				,@SourceFilter OUTPUT
				,@TargetFilter OUTPUT				
				,@TargetTableFQN
				,@SourceLinkedServer
				,@SourceDatabase
				;

		end
	--	select @DynSql, @DynSqlParmDefinition, @DynFilterOut
	set @SourceFilter = '(' + @SourceFilter + ')'
	set @TargetFilter = '(' + @TargetFilter + ')'

	if @SourceFilter is null and @TargetFilter is not null set @SourceFilter = @TargetFilter
	if @TargetFilter is null and @SourceFilter is not null set @TargetFilter = @SourceFilter

	set @TargetFilter = nullif(@TargetFilter, '')
	set @SourceFilter = nullif(@SourceFilter, '')
	--if @DynFilterOut is not null
	--	set @SourceFilter = isnull(@SourceFilter + ' and', '') + '(' + @DynFilterOut + ')'

	if @Debug = 1 print '-- @SourceFilter = ' + isnull(@SourceFilter, 'NULL')
	if @Debug = 1 print '-- @TargetFilter = ' + isnull(@TargetFilter, 'NULL')

	set @DynSQL = null
	
	if @SyncMethod = 2
		begin
			set @DynSQL = 'delete from ' + @TargetTableFQN +  ' with (tablock)'
			if exists(select 1 from #ColumnsInTarget where ColumnName = 'SA_SourceSystemID') and @SA_SourceSystemID is not null
				set @DynSQL =  @DynSQL + ' where SA_SourceSystemID = ' + cast(@SA_SourceSystemID as varchar(12))
		end
	else if @SyncMethod = 3
		begin
			set @DynSQL = 'delete from TargetTable from ' + @TargetTableFQN +  ' TargetTable with (tablock)'
			if exists(select 1 from #ColumnsInTarget where ColumnName = 'SA_SourceSystemID') and @SA_SourceSystemID is not null
				set @DynSQL =  @DynSQL + ' where SA_SourceSystemID = ' + cast(@SA_SourceSystemID as varchar(12)) + isnull(' and (' + @TargetFilter + ')', '')
			else
				set @DynSQL =  @DynSQL + isnull(' where ' + @TargetFilter, '')
		end
	else if @SyncMethod = 4
		begin
			-- Kontrollera om måltabellen är tom. Om så är fallet behövs ingen sync och vi insertar direkt till måltabellen.
			set @DynSQL = 'select top 1 1 as e from ' + @TargetTableFQN 
			if exists(select 1 from #ColumnsInTarget where ColumnName = 'SA_SourceSystemID') and @SA_SourceSystemID is not null
				set @DynSQL =  @DynSQL + ' where SA_SourceSystemID = ' + cast(@SA_SourceSystemID as varchar(12))
			declare @Dummy table(e int)
			insert into @Dummy
			exec (@DynSQL)

			if (select count(*) from @Dummy) = 0
				set @SyncMethod = -1 -- Ingen delete

			if @Debug = 1 and @SyncMethod = -1
				print '-- Ingen sync på grund av tom @TargetTable'

			set @DynSQL = null
		end

	if @DynSQL <> ''
		begin
			if @Debug = 1
				exec app.PrintMax @DynSQL
			else
				begin	
					exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
						,@EventTitle = 'Delete', @Description = ''
					exec (@DynSQL)

					exec app.LogEventStop @EventIDStack = @EventIDStack out
				end
		end

	
	set @Msg = 'insert/select från källsystem.'
	if isnull(@Debug, 0) = 0 exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output
			,@EventObject = @ProcName
			,@EventTitle = @Msg
			,@Description = ''

	/*
	declare @SourceTable varchar(150) = 'G_L Entry'
	declare @SourceLinkedServer sysname = 'NAVDB'
	declare @SourceDatabase sysname = 'Dynamics NAV 70 DB'
	declare @SourceTablePrefix sysname = '08 KH Sågverk-Råvara TEST'
	declare @SourceFilter varchar(max) = null
	declare @SA_SourceSystemID int = 1
	declare @TargetTable varchar(150) = 'sa.' + quotename(parsename(@SourceTable, 1))
	*/

	
	
	--set @DynSQL = 
	--	case when @SyncMethod = 4 then 
	--		''
	--	else '
	--	insert into ' + @TargetTable + ' with (tablock)(' + @TargetInsertList + ')'
	--	end
	--	+ '
	--	select
	--		' + @TargetSelectList 
	--	+
	--	case when @SyncMethod = 4 then '
	--	into #SourceData'
	--	else
	--		''
	--	end + '
	--	from
	--		openquery
	--		(
	--			' + quotename(parsename(@SourceLinkedServer, 1)) + '
	--			,
	--			''select ' + @SourceSelectList + 
	--			' from ' + @SourceDatabase + '.' + @SourceTable + ' with(nolock)' + isnull(' where ' + replace(@SourceFilter, '''', ''''''), '') + '''
				
	--		)
	--	;'
	--	+
	--	case when @SyncMethod = 4 then '
	--	exec [app].[SyncTable]
	--		@SourceTable = #SourceData
	--		,@TargetTable = ''' + @TargetTable + '''
	--		,@DeleteMode = 3 -- Endast insert/update'
	--	else
	--		''
	--	end + '
	--		'

	--select @SourceSelectList, @TargetInsertList

	
	set @DynSQL = '
		with SourceData('+ @TargetInsertList + ') as
		(
			'
			+		
		case @SourceSystemProviderID
		--
		-- SQL Server
		--
		when 1 then		
		case 
			when @LocalServer = 1 then
			'select ' + @TargetSelectList + ' ' +
			'from ' + @SourceDatabase + '.' + @SourceTableFQN + ' SourceTable with(nolock)' + isnull(' where ' + @SourceFilter, '') 
			else
			'
		select
			' + @TargetSelectList + '
		from
			openquery
			(
				' + quotename(@SourceLinkedServer) + '
				,
				''select ' + @SourceSelectList + 
				' from ' + isnull(@SourceDatabase + '.', '') + @SourceTableFQN + ' SourceTable with(nolock)' + isnull(' where ' + replace(@SourceFilter, '''', ''''''), '') + '''
				
			)'
		end
		--
		-- Oracle
		--
		else
		'
		select
			' + @TargetSelectList + '
		from
			openquery
			(
				' + quotename(@SourceLinkedServer) + '
				,
				''select ' + @SourceSelectList + 
				' from ' + isnull(@SourceDatabase + '.', '') + @SourceTableFQN + ' SourceTable' + isnull(' where ' + replace(@SourceFilter, '''', ''''''), '') + '''
				
			)'
		end

		+ '
		)'
		+
		case when @SyncMethod = 4 then '
		select
			'+ @TargetInsertList + '
		into
			#SourceData
		from
			SourceData;

		exec @RowCnt = [app].[SyncTable]
			@SourceTable = #SourceData
			,@TargetTable = ''' + @TargetTableFQN + '''
			,@DeleteMode = 3 -- Endast insert/update
			,@SupressWarnings = 1;'
			
		else '
		insert into ' + @TargetTableFQN + ' with (tablock)(' + @TargetInsertList + ')
		select
			'+ @TargetInsertList + '
		from
			SourceData;
		set @RowCnt = @@ROWCOUNT;'
		end + '
			'


	--exec app.PrintMax @DynSQL
	if isnull(@Debug, 0) = 0 
		begin
			set @DynSqlParmDefinition = '@RowCnt int out'
			exec sp_executesql @DynSql, @DynSqlParmDefinition,
				@RowCnt out
			--exec (@DynSQL)
		end
		
	else
		exec app.PrintMax @DynSQL
	

	set @Msg =  'ROWCOUNT = ' + cast(@RowCnt as varchar(12)) + ': ' + isnull(@SourceLinkedServer + '.', '') + @SourceDatabase + '.' + @SourceTableFQN + isnull(' where ' + @SourceFilter, '')
	if isnull(@Debug, 0) = 0 exec app.LogEventStop @EventIDStack = @EventIDStack out, @Description = @Msg
	--------------------------------------------------------------------------	
end try
begin catch	
	--
	-- Rulla tillbaka eventualla transaktioner startade i den här procedurn och logga fel.
	--
	if @TranCount = 0 and @@trancount > 0 rollback tran
	exec app.HandleProcError @EventIDStack out, @ParentEventID, @ProcName
	exec app.ReThrowError
end catch
GO
