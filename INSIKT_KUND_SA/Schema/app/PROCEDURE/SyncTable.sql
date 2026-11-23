SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[SyncTable]
(
	@SourceTable sysname -- Källtabell
	,@TargetTable sysname -- Måltabell
	,@JoinColumns varchar(4000) = null -- Kolumner i joinvillkor mellan käll- och måltabell.
	,@VauleColumns varchar(4000) = null -- Värdekolumner vars data ska uppdateras
	,@DeleteMode int = null -- Hur ska borttag hanteras. 1 = Borttagna rader raderas, 2 = Borttagna rader markeras som borttagna via flaggan IsDeleted,  3 = Borttagna lämnas kvar (endast insert/update)
	,@DeleteColumn varchar(512) = null -- Kolumnnamn på flagga för markering av borttag (Defulat = IsDeleted)
	,@TargetFilter varchar(max) = null -- I de fall endast en delmängd ska synkroniseras används detta filter för att filtrera måltabellen att matcha källtabellens innehåll.
	,@ColumnMap varchar(max) = null -- Används i de fall käll och måltabell har olika kolumnnamn. Syntax: @ColumnMap = 'TargetColumnNamn1 = SourceColumnName1, ...
	,@SynchronizedBy nvarchar(512) = null -- Sträng för att ange vem som anropat proceduren (default suser_name)
	,@CreatedByColumn varchar(512) = null -- Namn på kolumn i måltabell som innehåller vem som skapat rad (default: CreatedBy)
	,@CreatedDateColumn varchar(512) = null -- Namn på kolumn i måltabell som innehåller när raden skapades (Default: CreatedDate)
	,@ModifiedByColumn varchar(512) = null -- Namn på kolumn i måltabell som innhåller vem som senast modifierade radern (Default: ModifiedBy)
	,@ModifiedDateColumn varchar(512) = null -- Namn på kolumn i måltabellen som innehåller när en rad senast modifierades (Default: ModifiedDate)
	,@SupressWarnings bit = 0 -- Ge ej varningar.
	,@Compability int = null -- 1: Generera SQL som fungerar i äldre versioner av SQL Serever, 0: Generera SQL som fungerar i nya versioner av SQL, NULL:  Autodetect.
	,@Debug bit = 0 -- Debugläge på eller av. Vid @Debug = 1 så skrivs synkroniserings-sqlen ut iställe för att exekveras.
)	
as

declare @ProcName sysname, @TranCount int
set @ProcName = coalesce(object_name(@@procid), 'No procedure name available')
set @TranCount = @@TRANCOUNT

set nocount on

---- SET XACT_ABORT ON will cause the transaction to be uncommittable
---- when the constraint violation occurs and other runtime errors occure. 
--set xact_abort on;

begin try
	if @Debug is null set @Debug = 0
	if @Compability is null
		begin
			set @Compability = 1
			select 
				@Compability = 		
					case
						when CAST(Item as int) > 9 then 0
						else 1
					end		
			from 
				app.Split(cast(serverproperty('ProductVersion') as varchar(100)), '.') where ListPos = 1
		end	
	--
	-- Användare som anropar denna procedur
	--
	if @SynchronizedBy is null 
		set @SynchronizedBy = suser_name()

	--
	-- Se till att samtliga angivna kolumnnamn är omgivna av []
	--	
	select
		@CreatedByColumn = quotename(parsename(@CreatedByColumn, 1))
		,@CreatedDateColumn = quotename(parsename(@CreatedDateColumn,1))
		,@ModifiedByColumn = quotename(parsename(@ModifiedByColumn,1))
		,@ModifiedDateColumn = quotename(parsename(@ModifiedDateColumn,1))

	--
	-- Konvertera @ColumnMap till en tabell med från och till-kolumn.
	--
	create table #ColumnMap
	(
		TargetColumnNameUnquoted sysname collate database_default not null
		,SourceColumnNameUnquoted sysname collate database_default not null primary key
	)
	insert into #ColumnMap
	(
		TargetColumnNameUnquoted
		,SourceColumnNameUnquoted
	)
	select
		TargetColumnNameUnquoted = parsename(mapTarget.Item, 1)
		,SourceColumnNameUnquoted = parsename(mapSource.Item, 1)
	from
		app.Split(@ColumnMap, ',') map
			cross apply app.Split(map.Item, '=') mapTarget
			cross apply app.Split(map.Item, '=') mapSource
	where
		mapTarget.ListPos = 1
		and mapSource.ListPos = 2
			

			
	--
	-- @SourceTableFQN och @TargetTableFQN innhåller databas, schema och namn på ett sådant sätt att object_id(...) returnerar rätt objekt.
	--
	declare @SourceTableFQN sysname
	declare @TargetTableFQN sysname

	declare @SourceDatabase sysname 
	set @SourceDatabase = quotename(parsename(@SourceTable, 3))
	declare @TargetDatabase sysname 
	set @TargetDatabase = quotename(parsename(@TargetTable, 3))


	declare @NewLine char(2)
	set @NewLine = CHAR(13) + CHAR(10)

	--
	-- I de fall som käll eller måltabell är temptabeller sätts databasen till tempdb.
	-- (det för att kunna läsa systemvyer och ta reda på columner, mm)
	--
	if @SourceDatabase is null and left(parsename(@SourceTable, 1), 1) = '#' 
		set @SourceDatabase = quotename('tempdb')
	if @TargetDatabase is null and left(parsename(@TargetTable, 1), 1) = '#' 
		set @TargetDatabase = quotename('tempdb')

	--
	-- Hjälpvariabler som lätt kan sprängas in i genererat merge-skript
	--
	declare @SQL_SourceDatabase varchar(512) 
	set @SQL_SourceDatabase = isnull(@SourceDatabase + '.', '')
	declare @SQL_TargetDatabase varchar(512)
	set @SQL_TargetDatabase = isnull(@TargetDatabase + '.', '')

	--
	-- Det händer att det är LÅNGA låsningar i sys tabeller i tempdb som ligger utom vår makt. Av den anledningen använder vi with (nolock) i samtliga läsningar därifrån.
	--
	declare @SQL_SourceTempdbNoLock varchar(512)
	select @SQL_SourceTempDbNoLock =case when @SourceDatabase = 'tempdb' then ' with (nolock)' else '' end 
	declare @SQL_TargetTempdbNoLock varchar(512)
	select @SQL_TargetTempDbNoLock =case when @TargetDatabase = 'tempdb' then ' with (nolock)' else '' end 
	--
	-- Slaskvariabel för dynamisk sql
	--
	declare @SQL_Temp varchar(max)


	--
	-- Se till att tabellnamn är quotade på ett korrekt sätt.
	--
	select
		@SourceTableFQN = isnull(nullif(@SourceDatabase, quotename(db_name())) + '.', '') +
			 isnull(quotename(parsename(@SourceTable, 2)), '') + '.' +
			 quotename(parsename(@SourceTable,1))
		,@TargetTableFQN = isnull(nullif(@TargetDatabase, quotename(db_name())) + '.', '') +
			 isnull(quotename(parsename(@TargetTable, 2)), '') + '.' +
			 quotename(parsename(@TargetTable,1))
			 
		,@SourceTable = 
			isnull(quotename(parsename(@SourceTable, 3)) + '.', '')
			+ isnull(quotename(parsename(@SourceTable, 2)) + '.', '')
			+ quotename(parsename(@SourceTable, 1))
		,@TargetTable = 
			isnull(quotename(parsename(@TargetTable, 3)) + '.', '')
			+ isnull(quotename(parsename(@TargetTable, 2)) + '.', '')
			+ quotename(parsename(@TargetTable, 1))
			 

	--
	-- Kontrollera om käll och måltabelerna finns.
	--
	if object_id(@TargetTableFQN) is null
		raiserror ('Target table %s does not exists.', 16, 10, @TargetTable)

	if object_id(@SourceTableFQN) is null
		raiserror ('Source table %s does not exists.', 16, 10, @SourceTable)



	--
	-- Tabell innhållande joinkolumner
	--
	create table #JoinColumns
	(	
		ColumnID int not null identity(1,1)
		,TargetColumnName sysname collate database_default -- QuotedName
		,SourceColumnName sysname collate database_default -- QuotedName
		,TargetColumnNameUnquoted as cast(parsename(TargetColumnName,1) as sysname)
	)
	--
	-- Leta reda på joinkolumner
	-- OBS! SourceName sätts här till TargetName men uppdateras senare vid behov.
	--
	if len(@JoinColumns) > 0
		--
		-- I de fall @JoinColumns är satt så används de kolumnerna som joinkolumner.
		--
		insert into #JoinColumns(TargetColumnName, SourceColumnName)
		select
			quotename(parsename(Item, 1))
			,quotename(parsename(Item, 1)) 
		from
			app.SplitEscape(@JoinColumns, ',')
	else
		--
		-- Om inga joinkolumner är angivna används måltabellens primary-key-kolumner som joinkolumner.
		--
		insert into #JoinColumns(TargetColumnName, SourceColumnName)
		exec
		(
			'
			select
				quotename(col_name(ic.object_id,ic.column_id))
				,quotename(col_name(ic.object_id,ic.column_id))
			from
				' + @SQL_TargetDatabase + 'sys.objects t' + @SQL_TargetTempdbNoLock + '
					inner join ' + @SQL_TargetDatabase + 'sys.indexes i' + @SQL_TargetTempdbNoLock + ' on
						i.object_id = t.object_id
					inner join ' + @SQL_TargetDatabase + 'sys.schemas s' + @SQL_TargetTempdbNoLock + ' on
						s.schema_id = t.schema_id
					inner join ' + @SQL_TargetDatabase + 'sys.index_columns as ic' + @SQL_TargetTempdbNoLock + ' on
						i.object_id = ic.object_id
						and i.index_id = ic.index_id		
			where
				i.is_primary_key = 1
				and t.object_id = object_id(''' + @TargetTableFQN + ''')
			'
		)


	--
	-- Tabell fylls med information om käll- och måltabellens kolumner.
	--
	create table #ColumnData
	(
		ColumnID int not null identity(1,1)
		,ColumnName sysname not null primary key
		
		,SourceColumnName varchar(512) collate database_default
		,TargetColumnName varchar(512) collate database_default
		
		,ExistsInSource bit not null
		,ExistsInTarget bit not null
		,InValueParam bit not null
		,IsJoinColumn bit not null
		,TargetIsIdentity bit not null
		,TargetIsNullable bit not null
		,TargetIsDeleteColumn bit not null
		,TargetIsCreatedBy bit not null
		,TargetIsCreatedDate bit not null
		,TargetIsModifiedBy bit not null
		,TargetIsModifiedDate bit not null
		,TargetSystemType int
		,SourceSystemType int
		,SourceIsNullable bit not null
	)

	select
		@SQL_Temp = 
			'
			;with SourceColumns as
			(
				select
					*
				from
					' + @SQL_SourceDatabase + 'sys.columns srcJoinCol' + @SQL_SourceTempdbNoLock + '
				where
					srcJoinCol.object_id = object_id(''' + @SourceTableFQN + ''')
			)
			,
			TargetColumns as
			(
				select
					*
				from
					' + @SQL_TargetDatabase + 'sys.columns destJoinCol' + @SQL_TargetTempdbNoLock + '
				where
					destJoinCol.object_id = object_id(''' + @TargetTableFQN + ''')
					and destJoinCol.is_computed = 0					
			)
			select
				ColumnName = quotename(coalesce(destJoinCol.name collate database_default, srcJoinCol.name collate database_default, parsename(valueCols.Item, 1), joinCol.TargetColumnNameUnquoted collate database_default))
				
				,SourceColumnName = quotename(srcJoinCol.name)
				,TargetColumnName = quotename(destJoinCol.name)
				
				,ExistsInSource = case when srcJoinCol.object_id is not null then 1 else 0 end
				,ExistsInTarget = case when destJoinCol.object_id is not null then 1 else 0 end
				,InValueParam = case when valueCols.Item is not null then 1 else 0 end	
				,IsJoinColumn = case when joinCol.ColumnID is not null then 1 else 0 end
				,TargetIsIdentity = isnull(destJoinCol.is_identity, 0)
				,TargetIsNullable = isnull(destJoinCol.is_nullable, 0)
				,TargetIsDeleteColumn = case when destJoinCol.name = ''' + isnull(parsename(@DeleteColumn, 1), 'IsDeleted') + ''' then 1 else 0 end
				,TargetIsCreatedBy = case when destJoinCol.name = ''' + isnull(parsename(@CreatedByColumn, 1), 'CreatedBy') + '''' + case when @CreatedByColumn is null then ' and srcJoinCol.object_id is null ' else '' end + ' then 1 else 0 end
				,TargetIsCreatedDate = case when destJoinCol.name = ''' + isnull(parsename(@CreatedDateColumn, 1), 'CreatedDate') + '''' + case when @CreatedDateColumn is null then ' and srcJoinCol.object_id is null ' else '' end + ' then 1 else 0 end
				,TargetIsModifiedBy = case when destJoinCol.name = ''' + isnull(parsename(@ModifiedByColumn, 1), 'ModifiedBy') + '''' + case when @ModifiedByColumn is null then ' and srcJoinCol.object_id is null ' else '' end + ' then 1 else 0 end
				,TargetIsModifiedDate = case when destJoinCol.name = ''' + isnull(parsename(@ModifiedDateColumn, 1), 'ModifiedDate') + '''' + case when @ModifiedDateColumn is null then ' and srcJoinCol.object_id is null ' else '' end + ' then 1 else 0 end
				,TargetSystemType = destJoinCol.system_type_id
				,SourceSystemType = srcJoinCol.system_type_id	
				,SourceIsNullable = isnull(srcJoinCol.is_nullable, 0)		
			from
				SourceColumns srcJoinCol
					left join #ColumnMap map on
						map.SourceColumnNameUnquoted collate database_default = srcJoinCol.name collate database_default
					full join TargetColumns destJoinCol on
						destJoinCol.name  collate database_default = isnull(map.TargetColumnNameUnquoted, srcJoinCol.name) collate database_default
					full join #JoinColumns joinCol on
						joinCol.TargetColumnNameUnquoted collate database_default = srcJoinCol.name collate database_default
					full join app.Split(' + isnull('''' + @VauleColumns + '''', 'NULL') + ', '','') valueCols on
						parsename(valueCols.Item, 1) collate database_default = isnull(srcJoinCol.name, destJoinCol.name) collate database_default
		'

--print @SQL_Temp
	insert into #ColumnData
	(
		ColumnName	
		,SourceColumnName
		,TargetColumnName	
		,ExistsInSource
		,ExistsInTarget
		,InValueParam
		,IsJoinColumn
		,TargetIsIdentity
		,TargetIsNullable
		,TargetIsDeleteColumn
		,TargetIsCreatedBy
		,TargetIsCreatedDate
		,TargetIsModifiedBy
		,TargetIsModifiedDate
		,TargetSystemType
		,SourceSystemType
		,SourceIsNullable
	)
	exec(@SQL_Temp)

	--
	-- Uppdatera SourceColumnName till korrekt namn (i de fall @ColumnMap används)
	--
	update jc set 
		SourceColumnName = cd.SourceColumnName
	from
		#JoinColumns jc
			inner join #ColumnData cd on
				cd.TargetColumnName = jc.TargetColumnName
				and cd.SourceColumnName <> jc.SourceColumnName



	--
	-- Leta efter konstigheteter
	--
	declare @ErrorMessage varchar(max)
	declare @WarningMessage varchar(max)


	--
	-- Kontrollera så att joinkolumner finns med i både käll och måltabel
	--
	select 
		@ErrorMessage = isnull(@ErrorMessage + @NewLine, '') +
			'Join column ' + c.ColumnName + ' is missing in ' +
				case	
					when c.ExistsInSource = 0 and c.ExistsInTarget = 0 then
						'both ' + @SourceTable + ' and ' + @TargetTable
					when c.ExistsInSource = 0 then
						@SourceTable
					else
						@TargetTable
				end
				
	from
		#ColumnData c
	where
		c.IsJoinColumn = 1
		and 
		(
			c.ExistsInSource = 0 
			or c.ExistsInTarget = 0
		)	

	--
	-- Kontrollera så att värdekolumner finns med i båda tabellerna.
	--
	select 
		@ErrorMessage = isnull(@ErrorMessage + @NewLine, '') +
			'Value column ' + c.ColumnName + ' is missing in ' +
				case	
					when c.ExistsInSource = 0 and c.ExistsInTarget = 0 then
						'both ' + @SourceTable + ' and ' + @TargetTable
					when c.ExistsInSource = 0 then
						@SourceTable
					else
						@TargetTable
				end
				
	from
		#ColumnData c
	where
		c.InValueParam = 1
		and 
		(
			c.ExistsInSource = 0 
			or c.ExistsInTarget = 0
		)

	--select * from #ColumnData	
		
	--
	-- AutoDetect på DeleteMod ei de fall DeleteMode inte är satt.
	-- 1 = Ta bort rader
	-- 2 = Flagga borttagna rader
	--	
	if (@DeleteMode is null) 
		if (exists(select 1 from #ColumnData c where c.TargetIsDeleteColumn = 1) or @DeleteColumn is not null)
			--
			-- Ingen @DeleteMode är satt men kolumnen IsDeleted finns i måltabellen. DeleteMode sätts till 2
			--
			set @DeleteMode = 2
		else
			begin
				--
				-- @Ingen DeleteMode är satt och ingen IsDeleted-kolumn finns i måltabellen. DeleteMode sätts till 1
				--
				set @DeleteMode = 1
				update #ColumnData set TargetIsDeleteColumn = 0 where TargetIsDeleteColumn = 1
			end


	--
	-- Kontrollera DeleteMode 2 - Flaggning av borttatg
	--	
	if @DeleteMode = 2 
		begin
			--
			-- Kontrollera så att kolumn för at markera borttag verkligen finns med i måltabellen
			--
			if not exists(select 1 from #ColumnData c where c.TargetIsDeleteColumn = 1)
				select 
					@ErrorMessage = isnull(@ErrorMessage + @NewLine, '') +
						'Delete method requiers a target column to mark removed rows. Add a bit column named ' + isnull(@DeleteColumn, 'IsDeleted') + ' in target table ' + @TargetTable + ' or specify another column with parameter @DeleteColumn.'

			--
			-- I de fall kolumn för att markera borttag finns med i både käll- och måltabel finns risk att kolumnen blandas ihop med värdekolumner.
			-- Varna för detta.
			--
			select @WarningMessage = isnull(@ErrorMessage + @NewLine, '') +
				'Warning: DeleteColumn ' + c.ColumnName + ' exists in both source and target table.' 
			from
				#ColumnData c
			where 
				c.TargetIsDeleteColumn = 1 
				and c.ExistsInSource = 1
				and @DeleteColumn is null
			
			
			--
			-- Kontrollera datatyp på kolumn för att markera borttag
			--
			select 
				@ErrorMessage = isnull(@ErrorMessage + @NewLine, '') +
					'Delete column ' + c.ColumnName + ' of target table must be of type bit.' 
			from
				#ColumnData c
			where
				c.TargetIsDeleteColumn = 1
				and c.TargetSystemType not in (select system_type_id from sys.types where name in ('bit', 'smallint', 'bigint'))
						
		end

	--
	-- Kontrollera så att deletemode är satt till ett giltigt värde
	--
	if @DeleteMode not in (1,2,3)
		select @ErrorMessage = isnull(@ErrorMessage + @NewLine, '') +
				'Invalid @DeleteMode ' + isnull(CAST(@DeleteMode as varchar(13)), 'NULL') + '. Set @DeleteMode to 1 (delete removed rows) or 2 (set IsDeleted flag) or 3 (only INSERT/UPDATE).'


	--
	-- Kontrollera om angivna kolumner för CreatedBy, CreatedDate, ModifiedBy och ModifiedDate verkligen finns
	--
	if @CreatedByColumn is not null and not exists(select 1 from #ColumnData c where c.TargetIsCreatedBy = 1)
		select @ErrorMessage = isnull(@ErrorMessage + @NewLine, '') +
				'Column ' + @CreatedByColumn + ' does not exist in target table ' + @TargetTable + '.'
				
	if @CreatedDateColumn is not null and not exists(select 1 from #ColumnData c where c.TargetIsCreatedDate = 1)
		select @ErrorMessage = isnull(@ErrorMessage + @NewLine, '') +
				'Column ' + @CreatedDateColumn + ' does not exist in target table ' + @TargetTable + '.'
				
	if @ModifiedByColumn is not null and not exists(select 1 from #ColumnData c where c.TargetIsModifiedBy = 1)
		select @ErrorMessage = isnull(@ErrorMessage + @NewLine, '') +
				'Column ' + @ModifiedByColumn + ' does not exist in target table ' + @TargetTable + '.'
				
	if @ModifiedDateColumn is not null and not exists(select 1 from #ColumnData c where c.TargetIsModifiedDate = 1)
		select @ErrorMessage = isnull(@ErrorMessage + @NewLine, '') +
				'Column ' + @ModifiedDateColumn + ' does not exist in target table ' + @TargetTable + '.'

	
	--
	-- Ta bort rader från #ColumnData som inte behövs för vår merge-fråga.
	--
	delete from #ColumnData
	where
		not
		(
			--
			-- Joinkolumner
			--
			IsJoinColumn = 1 
			
			--
			-- Värdekolumner som angivits vi @ValueColumns
			--
			or InValueParam = 1
			
			--
			-- I de fall som inga kolumner har angivits via @ValueColumns används samtliga kolumner som finns med i både
			-- käll- och måltabell som värdekolumner.
			--
			or
			(			
				len(isnull(@VauleColumns, '')) = 0 
				and ExistsInSource = 1 
				and ExistsInTarget = 1
			)
			
			--
			-- I de fall @DeleteMode är 2 behöver vi kolumnen för att flagga borttag.
			--
			or 
			(			
				@DeleteMode = 2
				and TargetIsDeleteColumn = 1			
			)

			--
			-- I de fall @DeleteMode är 3 (insert/update) och mottagande kolumn har en IsDeleted-kolumn behöver vi hantera den för att klara undelete.
			--
			or 
			(			
				@DeleteMode = 3
				and TargetIsDeleteColumn = 1			
				and ExistsInSource = 0
				and ExistsInTarget = 1
			)
			
			--
			-- Kolumner för att spåra förändringar
			--		
			or TargetIsCreatedBy = 1
			or TargetIsCreatedDate = 1
			or TargetIsModifiedBy = 1
			or TargetIsModifiedDate = 1
		)


	--
	-- En kolumn kan inte vara både en joinkolumn och en värdekolumn på samma gång.
	--
	select 
		@ErrorMessage = isnull(@ErrorMessage + @NewLine, '') +
			'Column ' + c.ColumnName + ' cannot be both a join column and a value column.' 
	from
		#ColumnData c
	where
		c.IsJoinColumn = 1
		and c.InValueParam = 1


	--
	-- Joinkolumner måste finnas.
	--
	if not exists(select 1 from #ColumnData where IsJoinColumn = 1)	
		select 
			@ErrorMessage = isnull(@ErrorMessage + @NewLine, '') +
				'No join columns found. Use parameter @JoinColumns to specify join columns.'

		
	--
	-- Varna i de fall datatypen skiljer i käll och måltabell
	--
	select 
		@WarningMessage = isnull(@WarningMessage + @NewLine, '') +
			'Warning: Column ' + c.ColumnName + ' has different data type in source and target table.' 
	from
		#ColumnData c
	where
		c.SourceSystemType <> c.TargetSystemType
		

	--
	-- I de fall en värdekolumn i måltabellen är satt till Identity går det inte att uppdatera detta värde och av den anledningen skapas en varning.
	--	
	select 
		@WarningMessage = isnull(@WarningMessage + @NewLine, '') +
			'Warning: Target column ' + c.ColumnName + ' is an identity column and can not be updated. New rows have the correct value, but changes are ignored.' 
	from
		#ColumnData c
	where
		c.IsJoinColumn = 0
		and c.TargetIsIdentity = 1


	--
	-- Varna och presentera felmeddelanden.
	--	
	if len(@WarningMessage) > 0 and @SupressWarnings = 0
		raiserror(@WarningMessage, 10,1)
	if len(@ErrorMessage) > 0
		begin
			raiserror(@ErrorMessage, 16,10)
			return
		end


	--
	-- Hjälptabell innhållande värdekolumner för att generera SQL
	--
	create table #ValueColumns
	(
		ColumnID int not null primary key
		,TargetColumnName sysname collate database_default
		,SourceColumnName varchar(512) collate database_default
		,SqlUpdateCheck varchar(max) collate database_default
		,SqlUpdateSet varchar(max) collate database_default
		,SqlInsertExpression varchar(max) collate database_default
	)


	--
	-- Inserta värdekolumner
	-- Samtliga kolumner som finns kvar i #ColumnData förutom de som är joinkolumner ses som värdekolumner.
	--
	insert into #ValueColumns
	(
		ColumnID
		,TargetColumnName
		,SourceColumnName
		,SqlUpdateCheck
		,SqlUpdateSet
		,SqlInsertExpression
		
	)
	select
		c.ColumnID
		,c.TargetColumnName
		,c.SourceColumnName
		--
		-- Vilkor för att identifiera förändring på en värdekolumner.
		--
		,sqlUpdateCheck =
			case
				--
				-- För kolumn för borttagsmarkering sätter vi alltid villkoret " = 0"
				-- Det för att för att en "undelete" ska identifieras.
				--
				when c.TargetIsDeleteColumn = 1 then
					'(dest.' + c.TargetColumnName + ' = 1)'
					
				--
				-- I de fall målkolumnen tillåter null måste vi specialhantera null
				-- annars en helt vanlig jämförelse
				--
				when c.TargetIsNullable = 1 then
					'(src.' + c.SourceColumnName + ' <> dest.' + c.TargetColumnName + 
					' or (src.' + c.SourceColumnName + ' is null and dest.' + c.TargetColumnName + ' is not null)' + 
					' or (src.' + c.SourceColumnName + ' is not null and dest.' + c.TargetColumnName + ' is null))'
				else
					'src.' + c.SourceColumnName + ' <> dest.' + c.TargetColumnName
			end
			
		--
		-- Tilldelenings SQL vid förändring
		--	
		,sqlUpdateSet = 
			case
				--
				-- Ändrad av sätts till @SynchronizedBy
				--
				when c.TargetIsModifiedBy = 1 then
					c.TargetColumnName + ' = ''' + @SynchronizedBy + ''''
					
				--
				-- Tidpunkt för förändring sätts till getdate()
				--	
				when c.TargetIsModifiedDate = 1 then
					c.TargetColumnName + ' = getdate()'
					
				--
				-- Flagga för borttag sätts alltid till 0 vid förändring
				-- (i de fall den ska sättas till 1 så kommer vi aldrig få en match)
				--
				when c.TargetIsDeleteColumn = 1 then
					c.TargetColumnName + ' = 0'
					
				--
				-- För övriga kolumner sätts målkolumn = källkolumn
				--
				else
					c.TargetColumnName + ' = src.' + c.SourceColumnName
			end
			
		--
		-- Värde för kolumnen vid insert.
		--
		,SqlInsertExpression =
			case
				when c.TargetIsCreatedBy = 1 then
					'''' + @SynchronizedBy + ''''
				when c.TargetIsCreatedDate = 1 then
					'getdate()'				
				when c.TargetIsDeleteColumn = 1 then
					'0'
				else
					'src.' + c.SourceColumnName
			end	
	from
		#ColumnData c
	where
		c.IsJoinColumn = 0
		
		

	--
	-- Variabel som kommer att innhålla vår dynamisk ihopbyggda merge-fråga.
	--
	declare 
		@SQL_Merge varchar(max)
	set @SQL_Merge = ''
		

	declare @UpdateNeeded bit
	
	if exists
	(
		select 1
		from
			#ValueColumns c
				inner join #ColumnData cd on
					cd.ColumnID = c.ColumnID
		where
			cd.TargetIsIdentity = 0 -- Det är inte möjlig att uppdatera identity-kolumner och därför görs ingen kontroll om kolumnen är förändrad
			and c.SqlUpdateCheck is not null			
			and cd.TargetIsDeleteColumn = 0
	)
		set @UpdateNeeded = 1
	else
		set @UpdateNeeded = 0


	if len(@TargetFilter) > 0 
		select @SQL_Merge = @SQL_Merge +
			';with TargetFilter as' + @NewLine +
			'(' + @NewLine +
			'	select' + @NewLine +
			'		*' + @NewLine +
			'	from' + @NewLine +
			'		' + @TargetTable + @NewLine +
			'	where' + @NewLine +
			'		' + @TargetFilter + @NewLine +
			')' + @NewLine
			
	if @Compability = 0
		begin		
			select @SQL_Merge = @SQL_Merge +		
				'merge ' + case when len(@TargetFilter) > 0 then 'TargetFilter' else @TargetTable end + ' as dest' + @NewLine +
				'using ' + @SourceTable + ' as src on' + @NewLine
				
			select @SQL_Merge = @SQL_Merge + '	' + case when (c.ColumnID > 1) then 'and ' else '' end + 
				case when cd.TargetIsNullable = 1 and cd.SourceIsNullable = 1 then
					'(src.' +  c.SourceColumnName + ' = dest.' + c.TargetColumnName + ' or (src.' +  c.SourceColumnName + ' is null and dest.' + c.TargetColumnName + ' is null))'
				else				
					'src.' +  c.SourceColumnName + ' = dest.' + c.TargetColumnName
				end + @NewLine
			from
				#JoinColumns c
					inner join #ColumnData cd on
						cd.TargetColumnName = c.TargetColumnName
			order by
				c.ColumnID
			
			if @UpdateNeeded = 1
				begin
					select @SQL_Merge = @SQL_Merge +
						'when matched and' + @NewLine +
						'	(' + @NewLine

					select @SQL_Merge = @SQL_Merge + '		' + case when (row_number() over (order by c.ColumnID) > 1) then 'or ' else '' end + 
						c.SqlUpdateCheck + @NewLine
					from
						#ValueColumns c
							inner join #ColumnData cd on
								cd.ColumnID = c.ColumnID
					where
						cd.TargetIsIdentity = 0 -- Det är inte möjlig att uppdatera identity-kolumner och därför görs ingen kontroll om kolumnen är förändrad
						and c.SqlUpdateCheck is not null
					order by
						c.ColumnID


						
					select @SQL_Merge = @SQL_Merge +	
						'	)' + @NewLine +
						'	then update set' + @NewLine


					select @SQL_Merge = @SQL_Merge + '		' + case when (row_number() over (order by c.ColumnID) > 1) then ',' else '' end + 
						c.SqlUpdateSet + @NewLine
					from
						#ValueColumns c
							inner join #ColumnData cd on
								cd.ColumnID = c.ColumnID
					where
						cd.TargetIsIdentity = 0 -- Det är inte möjlig att uppdatera identity-kolumner och därför uppdateras ej kolumnen.
						and c.SqlUpdateSet is not null
					order by
						c.ColumnID
							
				end

			select @SQL_Merge = @SQL_Merge +	
				'when not matched by target then' + @NewLine +
				'	insert' + @NewLine +
				'	(' + @NewLine

			select @SQL_Merge = @SQL_Merge + '		' + case when (row_number() over (order by c.ColumnID) > 1) then ',' else '' end + 
				c.TargetColumnName + @NewLine
			from
				#JoinColumns c
			order by
				c.ColumnID
				
			select @SQL_Merge = @SQL_Merge + '		,' + 
				c.TargetColumnName + @NewLine
			from
				#ValueColumns c
			where
				c.SqlInsertExpression is not null
			order by
				c.ColumnID


			select @SQL_Merge = @SQL_Merge +	
				'	)' + @NewLine +
				'	values' + @NewLine +
				'	(' + @NewLine

			select @SQL_Merge = @SQL_Merge + '		' + case when (row_number() over (order by c.ColumnID) > 1) then ',' else '' end + 
				'src.' + c.SourceColumnName + @NewLine
			from
				#JoinColumns c
			order by
				c.ColumnID
				
			select @SQL_Merge = @SQL_Merge + '		,' + 
				c.SqlInsertExpression + @NewLine
			from
				#ValueColumns c
			where
				c.SqlInsertExpression is not null
			order by
				c.ColumnID
				
				
			select @SQL_Merge = @SQL_Merge +	
				'	)' + @NewLine 
				
			if @DeleteMode <> 3 
				begin
					if @DeleteMode = 2
						begin
							select
								 @SQL_Merge = @SQL_Merge +
									'when not matched by source and dest.' + cd.TargetColumnName + ' = 0 then' + @NewLine +
									'	update set ' + @NewLine
							from
								#ColumnData cd
							where
								cd.TargetIsDeleteColumn = 1
								
							select
								 @SQL_Merge = @SQL_Merge + '		' + case when (row_number() over (order by c.ColumnID) > 1) then ',' else '' end + 
									case
										when cd.TargetIsDeleteColumn = 1 then
											c.TargetColumnName + ' = 1'
										when cd.TargetIsModifiedBy = 1 then
											c.SqlUpdateSet
										when cd.TargetIsModifiedDate = 1 then
											c.SqlUpdateSet
									end + @NewLine
							from
								#ValueColumns c
									inner join #ColumnData cd on
										cd.ColumnID = c.ColumnID
							where
								cd.TargetIsDeleteColumn = 1
								or (cd.TargetIsModifiedBy = 1 and c.SqlUpdateSet is not null)
								or (cd.TargetIsModifiedDate = 1 and c.SqlUpdateSet is not null)
						end
					else
						begin
							select @SQL_Merge = @SQL_Merge +	
								'when not matched by source then' + @NewLine +
								'	delete' + @NewLine
						end
				end
			select
				@SQL_Merge = @SQL_Merge +		
					';' + @NewLine +
					'select @@ROWCOUNT as RowsAffected' + @NewLine
		end
	else
		begin
			--
			-- Eftersom merge-statement är nytt i SQL 2008 och vi vill stödja även SQL 2005
			-- Implementeras nedan motsvarande funktionallitet med full join istället.			
			--
			
			--
			-- Vid en full join måste vi leta efter NULL-värde i kolumner för att kunna identifiera om vi fått träff eller
			-- ej på joinvilkoren. Detta är dock lite besvärligt om kolumner tillåter NULL.
			--
			-- Logiken blir därför att titta på en godtycklig kolumn som finns med i både käll- och måltabell som i måltabellen ej
			-- tillåter NULL. Finns det inte någon sådan kolumn tittar vi på samtliga gemensamma kolumner för att avgöra om vi får 
			-- träff eller ej. Det leder tock till problem i de fall en rad i käll eller måltabellen har värdet NULL i samtliga kolumner.			
			--
			declare 
				@SQL_InsertCheck nvarchar(max)
				,@SQL_DeleteCheck nvarchar(max)
			select top 1
				@SQL_InsertCheck =
					'dest.' + c.TargetColumnName + ' is null'
				,@SQL_DeleteCheck =
					'src.' +  c.SourceColumnName + ' is null'
			from 
				#ColumnData c
			where	
				c.TargetIsNullable = 0
				and c.ExistsInSource = 1 
				and c.ExistsInTarget = 1
			order by
				c.IsJoinColumn desc, c.ColumnID
				
							
			if @SQL_InsertCheck is null or @SQL_DeleteCheck is null
				select
					@SQL_InsertCheck = isnull(@SQL_InsertCheck + ' and ', '') +
						'dest.' + c.TargetColumnName + ' is null'
					,@SQL_DeleteCheck = isnull(@SQL_DeleteCheck + ' and ', '') +
						'src.' +  c.SourceColumnName + ' is null'
				from 
					#ColumnData c
				where	
					c.ExistsInSource = 1 
					and c.ExistsInTarget = 1
				order by
					c.ColumnID
				
				
			
		
			select @SQL_Merge = 'declare @RowsAffected int' + @NewLine + @SQL_Merge +
				'select' + @NewLine +			
				'	[__SYNC_ACTION__] = ' + @NewLine +
				'		case' + @NewLine +			
				'			when ' +  @SQL_DeleteCheck + ' then ''D''' + @NewLine +
				'			when ' + @SQL_InsertCheck + ' then ''I''' + @NewLine +
				'			else ''U''' + @NewLine +
				'		end' + @NewLine
			select @SQL_Merge = @SQL_Merge +
				'	,' + c.SourceColumnName + ' = isnull(src.' +  c.SourceColumnName + ', dest.' + c.TargetColumnName + ')' + @NewLine
			from
				#JoinColumns c
			order by
				c.ColumnID
			select @SQL_Merge = @SQL_Merge +
				'	,' + c.SourceColumnName + ' = src.' +  c.SourceColumnName + @NewLine
			from
				#ValueColumns c
			where
				SourceColumnName is not null
			order by
				c.ColumnID
			
				
			select @SQL_Merge = @SQL_Merge +
				'into' + @NewLine +
				'	#SyncResult' + @NewLine +
				'from' + @NewLine +
				'	' + case when len(@TargetFilter) > 0 then 'TargetFilter' else @TargetTable end + ' as dest' + @NewLine +
				'		' + case when @DeleteMode = 3 then 'right' else 'full' end + ' join ' + @SourceTable + ' src on' + @NewLine
			select @SQL_Merge = @SQL_Merge + '			' + case when (c.ColumnID > 1) then 'and ' else '' end + 
				case when cd.TargetIsNullable = 1 and cd.SourceIsNullable = 1 then
					'(src.' +  c.SourceColumnName + ' = dest.' + c.TargetColumnName + ' or (src.' +  c.SourceColumnName + ' is null and dest.' + c.TargetColumnName + ' is null))'
				else				
					'src.' +  c.SourceColumnName + ' = dest.' + c.TargetColumnName
				end + @NewLine
			from
				#JoinColumns c
					inner join #ColumnData cd on
						cd.TargetColumnName = c.TargetColumnName
			order by
				c.ColumnID

			
			select @SQL_Merge = @SQL_Merge +
				'where' + @NewLine
			select @SQL_Merge = @SQL_Merge +
				case 
					when @DeleteMode = 2 then
						--Innan NULL-fix:'	(src.' +  c.SourceColumnName + ' is null and dest.' + delCol.TargetColumnName + ' = 0)' + @NewLine + 
						'	(' +  @SQL_DeleteCheck + ' and dest.' + delCol.TargetColumnName + ' = 0)' + @NewLine + 						
						'	or '
					when @DeleteMode = 1 then
						--Innan NULL-fix:'	'	src.' +  c.SourceColumnName + ' is null' + @NewLine + 
						'	(' +  @SQL_DeleteCheck + ')' + @NewLine + 
						'	or '
					else ''
				end +
				--Innan NULL-fix:'dest.' + c.TargetColumnName + ' is null' + @NewLine
				'(' + @SQL_InsertCheck + ')' + @NewLine
			from
				#JoinColumns c
					left join #ColumnData delCol on
						delCol.TargetIsDeleteColumn = 1
			where
				c.ColumnID = 1

			if @UpdateNeeded = 1
				begin					
					select @SQL_Merge = @SQL_Merge +
						'	or' + @NewLine +
						'	(' + @NewLine
					select @SQL_Merge = @SQL_Merge +
						--Innan NULL-fix:'		src.' +  c.SourceColumnName + ' is not null' + @NewLine +
						--Innan NULL-fix:'		and dest.' +  c.TargetColumnName + ' is not null' + @NewLine
						'		not (' + @SQL_DeleteCheck  + ')' + @NewLine +
						'		and not (' +  @SQL_InsertCheck + ')' + @NewLine
					from
						#JoinColumns c				
					where
						c.ColumnID = 1
				
						
					select @SQL_Merge = @SQL_Merge +			
						'		and (' + @NewLine

					select @SQL_Merge = @SQL_Merge + '			' + case when (row_number() over (order by c.ColumnID) > 1) then 'or ' else '' end + 
						c.SqlUpdateCheck + @NewLine
					from
						#ValueColumns c
							inner join #ColumnData cd on
								cd.ColumnID = c.ColumnID
					where
						cd.TargetIsIdentity = 0 -- Det är inte möjlig att uppdatera identity-kolumner och därför görs ingen kontroll om kolumnen är förändrad
						and c.SqlUpdateCheck is not null			
						and cd.TargetIsDeleteColumn = 0
					order by
						c.ColumnID
					select @SQL_Merge = @SQL_Merge +
						'		)' + @NewLine +
						'	)' + @NewLine
				end
			select @SQL_Merge = @SQL_Merge +
				--Innan NULL-fix:'	or (src.' +  c.SourceColumnName + ' is not null and dest.' + delCol.TargetColumnName + ' = 1)' + @NewLine 
				'	or (not (' +  @SQL_DeleteCheck + ') and dest.' + delCol.TargetColumnName + ' = 1)' + @NewLine 
			from
				#JoinColumns c
					inner join #ColumnData delCol on
						delCol.TargetIsDeleteColumn = 1
			where
				c.ColumnID = 1
				
				
	--select @SQL_Merge = @SQL_Merge + @NewLine +
	--	'select * from #SyncResult' + @NewLine
		
			select @SQL_Merge = @SQL_Merge + @NewLine +
				'insert into ' + @TargetTable + @NewLine +			
				'(' + @NewLine

			select @SQL_Merge = @SQL_Merge + '	' + case when (row_number() over (order by c.ColumnID) > 1) then ',' else '' end + 
				c.TargetColumnName + @NewLine
			from
				#JoinColumns c
			order by
				c.ColumnID
				
			select @SQL_Merge = @SQL_Merge + '	,' + 
				c.TargetColumnName + @NewLine
			from
				#ValueColumns c
			where
				c.SqlInsertExpression is not null
			order by
				c.ColumnID


			select @SQL_Merge = @SQL_Merge +	
				')' + @NewLine +
				'select' + @NewLine			

			select @SQL_Merge = @SQL_Merge + '	' + case when (row_number() over (order by c.ColumnID) > 1) then ',' else '' end + 
				'src.' + c.SourceColumnName + @NewLine
			from
				#JoinColumns c
			order by
				c.ColumnID
				
			select @SQL_Merge = @SQL_Merge + '	,' + 
				c.SqlInsertExpression + @NewLine
			from
				#ValueColumns c
			where
				c.SqlInsertExpression is not null
			order by
				c.ColumnID
				
				
			select @SQL_Merge = @SQL_Merge +	
				'from' + @NewLine +
				'	#SyncResult src' + @NewLine +
				'where' + @NewLine +
				'	src.[__SYNC_ACTION__] = ''I''' + @NewLine +
				'select @RowsAffected = isnull(@RowsAffected, 0) + @@rowcount' + @NewLine +
				@NewLine	

			if @UpdateNeeded = 1
				begin
					select @SQL_Merge = @SQL_Merge +	
						'update dest set' + @NewLine
						


					select @SQL_Merge = @SQL_Merge + '	' + case when (row_number() over (order by c.ColumnID) > 1) then ',' else '' end + 
						c.SqlUpdateSet + @NewLine
					from
						#ValueColumns c
							inner join #ColumnData cd on
								cd.ColumnID = c.ColumnID
					where
						cd.TargetIsIdentity = 0 -- Det är inte möjlig att uppdatera identity-kolumner och därför uppdateras ej kolumnen.
						and c.SqlUpdateSet is not null
					order by
						c.ColumnID
							

					select @SQL_Merge = @SQL_Merge +	
						'from' + @NewLine +
						'	#SyncResult src' + @NewLine +
						'		inner join ' + @TargetTable + ' dest on' + @NewLine
					select @SQL_Merge = @SQL_Merge + '			' + case when (c.ColumnID > 1) then 'and ' else '' end + 
						--'src.' +  c.SourceColumnName + ' = dest.' + c.TargetColumnName + @NewLine
						case when cd.TargetIsNullable = 1 then
							'(src.' +  c.SourceColumnName + ' = dest.' + c.TargetColumnName + ' or (src.' +  c.SourceColumnName + ' is null and dest.' + c.TargetColumnName + ' is null))'
						else				
							'src.' +  c.SourceColumnName + ' = dest.' + c.TargetColumnName
						end + @NewLine
					from
						#JoinColumns c
							inner join #ColumnData cd on
								cd.TargetColumnName = c.TargetColumnName
					order by
						c.ColumnID
					/*
								select @SQL_Merge = @SQL_Merge + '			' + case when (c.ColumnID > 1) then 'and ' else '' end + 
						case when cd.TargetIsNullable = 1 then
							'(src.' +  c.SourceColumnName + ' = dest.' + c.TargetColumnName + ' or (src.' +  c.SourceColumnName + ' is null and dest.' + c.TargetColumnName + ' is null))'
						else				
							'src.' +  c.SourceColumnName + ' = dest.' + c.TargetColumnName
						end + @NewLine
					from
						#JoinColumns c
							inner join #ColumnData cd on
								cd.TargetColumnName = c.TargetColumnName
					order by
						c.ColumnID*/
						
					select @SQL_Merge = @SQL_Merge +	
						'where' + @NewLine +
						'	src.[__SYNC_ACTION__] = ''U''' + @NewLine +
						'select @RowsAffected = isnull(@RowsAffected, 0) + @@rowcount' + @NewLine +
						@NewLine					
				end	
				
			if @DeleteMode <> 3 
				begin				
					if @DeleteMode = 2
						begin
							select @SQL_Merge = @SQL_Merge +	
								'update dest set' + @NewLine
							select
								 @SQL_Merge = @SQL_Merge + '	' + case when (row_number() over (order by c.ColumnID) > 1) then ',' else '' end + 
									case
										when cd.TargetIsDeleteColumn = 1 then
											c.TargetColumnName + ' = 1'
										when cd.TargetIsModifiedBy = 1 then
											c.SqlUpdateSet
										when cd.TargetIsModifiedDate = 1 then
											c.SqlUpdateSet
									end + @NewLine
							from
								#ValueColumns c
									inner join #ColumnData cd on
										cd.ColumnID = c.ColumnID
							where
								cd.TargetIsDeleteColumn = 1
								or (cd.TargetIsModifiedBy = 1 and c.SqlUpdateSet is not null)
								or (cd.TargetIsModifiedDate = 1 and c.SqlUpdateSet is not null)
							select @SQL_Merge = @SQL_Merge +	
								'from' + @NewLine +
								'	#SyncResult src' + @NewLine +
								'		inner join ' + @TargetTable + ' dest on' + @NewLine
							select @SQL_Merge = @SQL_Merge + '			' + case when (c.ColumnID > 1) then 'and ' else '' end + 
								--'src.' +  c.SourceColumnName + ' = dest.' + c.TargetColumnName + @NewLine
								case when cd.TargetIsNullable = 1 then
									'(src.' +  c.SourceColumnName + ' = dest.' + c.TargetColumnName + ' or (src.' +  c.SourceColumnName + ' is null and dest.' + c.TargetColumnName + ' is null))'
								else				
									'src.' +  c.SourceColumnName + ' = dest.' + c.TargetColumnName
								end + @NewLine
							from
								#JoinColumns c
									inner join #ColumnData cd on
										cd.TargetColumnName = c.TargetColumnName
							order by
								c.ColumnID
							select @SQL_Merge = @SQL_Merge +	
								'where' + @NewLine +
								'	src.[__SYNC_ACTION__] = ''D''' + @NewLine +
								'select @RowsAffected = isnull(@RowsAffected, 0) + @@rowcount' + @NewLine +
								@NewLine
						end
					else
						begin
							select
								@SQL_Merge = @SQL_Merge +	
									'delete from dest' + @NewLine
							select @SQL_Merge = @SQL_Merge +	
								'from' + @NewLine +
								'	#SyncResult src' + @NewLine +
								'		inner join ' + @TargetTable + ' dest on' + @NewLine
							select @SQL_Merge = @SQL_Merge + '			' + case when (c.ColumnID > 1) then 'and ' else '' end + 
								case when cd.TargetIsNullable = 1 then
									'(src.' +  c.SourceColumnName + ' = dest.' + c.TargetColumnName + ' or (src.' +  c.SourceColumnName + ' is null and dest.' + c.TargetColumnName + ' is null))'
								else				
									'src.' +  c.SourceColumnName + ' = dest.' + c.TargetColumnName
								end + @NewLine
							from
								#JoinColumns c
									inner join #ColumnData cd on
										cd.TargetColumnName = c.TargetColumnName
							order by
								c.ColumnID
							select @SQL_Merge = @SQL_Merge +	
								'where' + @NewLine +
								'	src.[__SYNC_ACTION__] = ''D''' + @NewLine +								
								'select @RowsAffected = isnull(@RowsAffected, 0) + @@rowcount' + @NewLine +
								@NewLine
						end
				end
			select
				@SQL_Merge = @SQL_Merge +					
					'drop table #SyncResult' + @NewLine + 
					'select @RowsAffected as RowsAffected' + @NewLine
		end
		
		
	if exists(select 1 from #ColumnData where /* (IsJoinColumn=1 or InValueParam=1) and */ TargetIsIdentity = 1)
		set @SQL_Merge = 
			'set identity_insert ' + @TargetTableFQN + ' on;' + @NewLine +
			@SQL_Merge + @NewLine +
			'set identity_insert ' + @TargetTableFQN + ' off;' + @NewLine
			
	--set @SQL_Merge = 
	--	'begin tran' + @NewLine +
	--	@SQL_Merge + @NewLine +			
	--	'commit tran' + @NewLine

	declare @RowAffected table(RowsAffected int)
	if @Debug = 0
		begin
			if @TranCount = 0 begin tran
			insert into @RowAffected(RowsAffected)
			exec (@SQL_Merge)
			if @TranCount = 0 commit tran			
		end
	else
		exec app.PrintMax @SQL_Merge


	drop table #ValueColumns
	drop table #JoinColumns
	drop table #ColumnData
	drop table #ColumnMap
	return (select isnull(SUM(RowsAffected), -1) from @RowAffected)
end try

begin catch
	--
	-- Rollback transactions
	--
	while @TranCount = 0 and @@trancount > 0 rollback tran	
	exec app.ReThrowError
	return -1
end catch
GO
