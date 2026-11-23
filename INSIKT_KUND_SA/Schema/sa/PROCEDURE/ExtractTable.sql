SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [sa].[ExtractTable]
(	
	@SourceTable varchar(150)
	,@SourceFilter varchar(max) = null	-- Filter som appliceras vid select från källtabell
	,@TargetTable nvarchar(150) = null
	,@TargetFilter varchar(max) = null	-- Filter som appliceras vid delete på sa-tabell innan insert från källsystem körs. 
										-- Om @SourceFilter är satt och @TargetTable är NULL används @SourceFilter även som @TargetFilter.										 

	,@DynamicFilterSetterQuery varchar(max) = null -- Select fråga som sätter parametrarna @SourceFilter och @TargetFilter
		-- Ex. som hämtar skapar filter på senast laddade DATE_ENTERED:
		-- OBS!
		-- I exemplet nedan används Oracle som provider och datetime-konstanter deklareras olika i oracle och sql server.
		-- Av den anledningen går det inte att applicera samma filter på delete-frågan i måltabellen i SA:t som i selecten
		-- från källtabellen (oracal)
		--
		-- I de fall exakt samma filter går att applicera på både delete och select-fråga räcker det med att tilldela @SourceFilter
		-- @SourceFilter används som @TargetFilter i de fall @TargetFilter är NULL
		--
		--	@DynamicFilterSetterQuery = 
		--		'
		--		select 
		--			@SourceFilter = ''DATE_ENTERED > TIMESTAMP '''''' + convert(varchar(max), MAX(DATE_ENTERED), 121) + ''''''''			
		--			,@TargetFilter = ''DATE_ENTERED > '''''' + convert(varchar(max), MAX(DATE_ENTERED), 121) + ''''''''			
		--		From 
		--			ifs.CUSTOMER_ORDER_LINE_HIST_TAB
		--		'
	,@SyncMethod int = null
		-- NULL = Auto (1 when SA_SourceSystemID is NULL and no SourceFilter, 2 when SA_SourceSystemID is not NULL and no SourceFilter. 3 When SourceFilter exists).
		-- 1	= Trucate target tabel before inserts
		-- 2	= Delete per company
		-- 3	= Use SourceFilter and TargetFilter on delete and insert
		-- 4	= Sync source rows with target
		-- -1	= No delete 
	--,@NoDelete bit = null
	--,@Truncate bit = null
	
	--,@SA_SourceSystemID int = null	
	,@SA_SourceSystemID nvarchar(max) = null

	,@TargetSchema nvarchar(50) = null
	--,@TargetTable varchar(150) = null
	
	,@ParentEventID int = null
	,@Debug bit = 0
)
as
set nocount on
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
	--
	-- Ta reda på vilka bolag som ska laddas
	--
	declare @Companies table(SA_SourceSystemID int not null primary key)
	insert into @Companies
	select
		c.SA_SourceSystemID
	from
		sa.base_SourceSystem c			
	where
		(c.SA_SourceSystemID in (select cast(lst.Item as int)  from app.Split(@SA_SourceSystemID, ',') lst) or @SA_SourceSystemID is null)
		and (c.TargetSchema = @TargetSchema or @TargetSchema is null)
	if @SyncMethod is null
		begin
			if @SourceFilter <> '' or @TargetFilter <> '' or @DynamicFilterSetterQuery <> ''
				set @SyncMethod = 3 -- Use SourceFilter/DynamicSourceFilter on delete
			else if @SA_SourceSystemID is not null
				set @SyncMethod = 2
			else set @SyncMethod = 1
		end
	
	declare @DefaultTargetSchema nvarchar(50)
	select
		@DefaultTargetSchema = c.TargetSchema
	from
		sa.base_SourceSystem c
			inner join @Companies cc on
				cc.SA_SourceSystemID = c.SA_SourceSystemID
	group by
		c.TargetSchema
	if @@ROWCOUNT > 1
		set @DefaultTargetSchema = null

	declare @TargetTableFQN nvarchar(512)

	if @TargetTable is null
		begin
			set @TargetTableFQN = quotename(isnull(parsename(isnull(@TargetSchema, @DefaultTargetSchema),1), 'dbo')) + '.' + quotename(parsename(@SourceTable, 1)) 
			set @TargetTable = @TargetTableFQN
		end
	else
		begin
			if left(parsename(@TargetTable, 1), 1) = '#'
				begin
					--Target it a temp table
					set @TargetTableFQN = quotename(parsename(@TargetTable, 1))

					if object_id('tempdb..' + @TargetTableFQN) is null
						begin
							raiserror('%s missing. Temp tables must be present before calling this procedure.', 16, 10, @TargetTable)							
						end
				end
			else
				begin
					--Target it not a temp table
					set @TargetTableFQN = 
						QUOTENAME -- schema
						(
							isnull
							(
								parsename(@TargetTable, 2) -- Schema from @TargetTable
								,isnull(parsename(isnull(@TargetSchema, @DefaultTargetSchema),1), 'dbo')
							)
						)
						+ '.'
						+ quotename(parsename(@TargetTable, 1))
					--coalesce(parsename(@TargetTable, 2), @TargetSchema, @DefaultTargetSchema)
				end
		end
	
	declare @Msg varchar(1000)
	declare @DynSQL varchar(max)
	declare @DynSQLFilter varchar(max)
	set @Msg = @TargetTableFQN
	
	if isnull(@Debug, 0) = 0 
		exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output
			,@EventObject = @ProcName
			,@EventTitle = @Msg
			,@Description = @Msg
	

	declare 	
		@SourceLinkedServer sysname
		,@SourceDatabase sysname
		,@SourceTablePrefix sysname
		,@CompanyDescription varchar(1000)
		,@SourceSystemProviderID int
	
	--
	-- Kontrollera om måltabellen finns
	--
	if object_id(@TargetTableFQN) is null and left(parsename(@TargetTable, 1), 1) <> '#'
		begin
			--
			-- Måltabellen saknas
			--
			declare 
				@Template_SA_SourceSystemID int
				,@Template_SA_SourceTableFQN nvarchar(512)			

			select @Template_SA_SourceSystemID = min(SA_SourceSystemID) from @Companies
			if @@ROWCOUNT = 0
				raiserror ('Target tabel %s missing. Execute sa.CreateSATableFromSource to create table.', 16, 10, @TargetTableFQN)

			select
				@Template_SA_SourceTableFQN = 
					ISNULL
					(
						QUOTENAME
						(
							parsename(@SourceTable, 2)
							,case when c.SourceSystemProviderID = 1 then '[' else '"' end -- Always ANSI IDENTIFIER for other providers than SQL Server
						)
						+
						'.'
						,
						''
					)
					+
					QUOTENAME
					(
						ISNULL(c.[TablePrefix], '') + parsename(@SourceTable, 1)
						,case when c.SourceSystemProviderID = 1 then '[' else '"' end -- Always ANSI IDENTIFIER for other providers than SQL Server
					)
			from 
				sa.base_SourceSystem c 
			where 
				c.SA_SourceSystemID = @Template_SA_SourceSystemID
			
			
			exec [sa].[CreateSATableFromSource]
				@SourceTable = @Template_SA_SourceTableFQN
				,@TargetTable = @TargetTableFQN
				,@SA_SourceSystemID = @Template_SA_SourceSystemID
				,@AddSaSourceSystemID = 1
				,@Debug = @Debug

			
		end


	
	
	
	if @SyncMethod = 1
		begin
			if isnull(@Debug, 0) = 0  
				begin
					exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
						,@EventTitle = 'Trunkera tabell',@Description = ''
				
					exec ('truncate table ' + @TargetTableFQN )
			
					exec app.LogEventStop @EventIDStack = @EventIDStack out
				end
			else
				print 'truncate table ' + @TargetTableFQN
		end
	


	
	declare @DynFilterOut varchar(max)	
	declare @DynSqlParmDefinition nvarchar(max);
	

	--
	-- Iterera igenom alla konfigurerade bolag och ladda data för dessa
	--
	declare @SourceTableFQN nvarchar(512)
	declare @SA_SourceSystemID_Iterator int	
	select @SA_SourceSystemID_Iterator = min(SA_SourceSystemID) from @Companies
	while @SA_SourceSystemID_Iterator is not null
		begin
			select 
				@Msg = 'Ladda ' + isnull(c.[Description], cast(c.SA_SourceSystemID as varchar(12)) + isnull(' ' + TablePrefix, '')) + ' (SA_SourceSystemID = ' +  cast(c.SA_SourceSystemID as varchar(12)) + ')'
				,@SourceLinkedServer = c.[LinkedServer]
				,@SourceDatabase = c.[Database]
				,@SourceTablePrefix = c.[TablePrefix]
				,@CompanyDescription = c.[Description]
				,@SourceSystemProviderID = c.SourceSystemProviderID
				,@SourceTableFQN = 
					ISNULL
					(
						QUOTENAME
						(
							parsename(@SourceTable, 2)
							,case when c.SourceSystemProviderID = 1 then '[' else '"' end -- Always ANSI IDENTIFIER for other providers than SQL Server
						)
						+
						'.'
						,
						''
					)
					+
					QUOTENAME
					(
						ISNULL(c.[TablePrefix], '') + parsename(@SourceTable, 1)
						,case when c.SourceSystemProviderID = 1 then '[' else '"' end -- Always ANSI IDENTIFIER for other providers than SQL Server
					)
			from 
				sa.base_SourceSystem c 
			where 
				c.SA_SourceSystemID = @SA_SourceSystemID_Iterator


			

			
				

			
			if isnull(@Debug, 0) = 0
				exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
					,@EventTitle = @Msg, @Description = ''
			else
				print '-- ' + @Msg

			exec sa.ExtractTableData
				@SyncMethod = @SyncMethod
				,@SA_SourceSystemID = @SA_SourceSystemID_Iterator
				,@SourceSystemProviderID = @SourceSystemProviderID
				,@SourceLinkedServer = @SourceLinkedServer
				,@SourceDatabase = @SourceDatabase
				,@SourceTableFQN = @SourceTableFQN
				,@TargetTableFQN = @TargetTableFQN
	
				,@SourceFilter = @SourceFilter
				,@TargetFilter = @TargetFilter
				,@DynamicFilterSetterQuery = @DynamicFilterSetterQuery				

				,@ParentEventID = @EventIDStack
				,@Debug = @Debug
			
			if isnull(@Debug, 0) = 0 
				exec app.LogEventStop @EventIDStack = @EventIDStack out
			select 
				@SA_SourceSystemID_Iterator = min(SA_SourceSystemID)
			from 
				@Companies
			where 
				SA_SourceSystemID > @SA_SourceSystemID_Iterator 
		end
		
	if isnull(@Debug, 0) = 0
		exec app.LogEventStop @EventIDStack = @EventIDStack out, @Description = @Msg
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
