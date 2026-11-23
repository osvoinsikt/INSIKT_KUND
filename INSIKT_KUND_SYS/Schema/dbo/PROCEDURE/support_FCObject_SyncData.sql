SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[support_FCObject_SyncData]
(
	--
	-- Källtabell vars utseende matchar FCObject-konfigurationen
	--
	@SourceTable sysname -- Källtabell

	--
	-- FCObjectTypeID
	--
	,@FCObjectTypeID int -- FCObject typ

	--
	-- Kommaseparerad lista med kolumner som tillsamans bildar "Primary Key"
	--
	,@PrimaryKeyColumns nvarchar(4000)  = null -- Kommaseparerad lista med kolumner i primärnyckel. Om null eller blank används FCObjectID som primärnyckel.

	--
	-- Hur synkningen ska gå till
	--
	-- 1 = INSERT/UPDATE/IsDELETED	- Delete innebär att IsDeleted-flaggan sätts.
	-- 2 = INSERT/UPDATE/DELETE		- Delete tar bort rader
	-- 3 = INSERT/UPDATE			- Lägger till och uppdaterar rader
	-- 4 = INSERT					- Lägger till rader. Kräver inga @PrimaryKeyColumns men risk för dubletter uppstår.
	,@Operation int = 1

	--
	-- Användare som markeras sätts i CreatedBy och ModifiedBy
	--
	,@ChangeUser int = null

	--
	-- Om 1 så skrivs visas genererad SQL-kod istället för att den exekveras.
	--
	,@Debug bit = 0
)
as

/*
declare
	@SourceTable sysname -- Källtabell
	,@FCObjectTypeID int -- FCObject typ
	,@PrimaryKeyColumns nvarchar(4000) -- Kommaseparerad lista med kolumner i primärnyckel. Om null eller blank används FCObjectID som primärnyckel.
	,@ChangeUser int



set @SourceTable = '#Test'
set @FCObjectTypeID = 1
set @PrimaryKeyColumns = 'Spärrid'
*/



declare @ProcName sysname, @TranCount int
set @ProcName = coalesce(object_name(@@procid), 'No procedure name available')
set @TranCount = @@TRANCOUNT

set nocount on

---- SET XACT_ABORT ON will cause the transaction to be uncommittable
---- when the constraint violation occurs and other runtime errors occure.
--set xact_abort on;

begin try
	if @Debug is null set @Debug = 0
	if @ChangeUser is null
		set @ChangeUser = (select UserID from UserSecurityGroup where UserName = suser_name())

	if @ChangeUser is null
		set @ChangeUser = -1

	declare @ChangeUserCasted nvarchar(10) = cast(@ChangeUser as nvarchar(10))

	declare @Error nvarchar(4000)

	if @Operation not in (1,2,3,4) or @Operation is null
		begin
			raiserror('@Operation %i is unknown and not supported.', 16, 10, @Operation)
			return
		end
	declare @IsStandAlone bit
	select
		@IsStandAlone = isnull(t.IsStandAlone, 1)
	from
		dbo.FCObjectType t
	where
		t.ID = @FCObjectTypeID


	if @@ROWCOUNT = 0
		begin
			raiserror('No FCObject type with ID %i exists', 16, 10, @FCObjectTypeID)
			return;
		end



	create table #KeyColumns
	(
		KeyColumns nvarchar(150) not null PRIMARY KEY,
	)


    if len(@PrimaryKeyColumns)>0
	begin
		declare @idx int
		declare @slice nvarchar(4000)

		select @idx = 1

		while @idx!= 0
		begin
			set @idx = charindex(',',@PrimaryKeyColumns)
			if @idx!=0
				set @slice = left(@PrimaryKeyColumns,@idx - 1)
			else
				set @slice = @PrimaryKeyColumns

			insert into #KeyColumns(KeyColumns) select (parsename(ltrim(rtrim(@slice)), 1))

			set @PrimaryKeyColumns = right(@PrimaryKeyColumns,datalength(@PrimaryKeyColumns)/2 - @idx)
			if len(@PrimaryKeyColumns) = 0 break
		end
	end

	if (not exists(select 1 from #KeyColumns) and @Operation <> 4) -- Inga KeyColumns krävs för Operation 4, Endast INSERT (risk för dubletter)
		begin
			insert into #KeyColumns(KeyColumns) values('FCObjectID')
			if @IsStandAlone = 0 insert into #KeyColumns(KeyColumns) values('FCObjectElementKey')
		end

	if @IsStandAlone = 0 and not exists(select 1 from #KeyColumns where KeyColumns = 'FCObjectElementKey')
		begin
			raiserror('When IsStandAlone = 0 FCObjectElementKey is a mandatory primary key column. Include it in @PrimaryKeyColumns parameter.', 16, 10)
			return
		end

	--
	-- @SourceTableFQN och @TargetTableFQN innhåller databas, schema och namn på ett sådant sätt att object_id(...) returnerar rätt objekt.
	--
	declare @SourceTableFQN sysname

	declare @SourceDatabase sysname
	set @SourceDatabase = quotename(parsename(@SourceTable, 3))


	declare @NewLine char(2)
	set @NewLine = CHAR(13) + CHAR(10)

	--
	-- I de fall som källtabell är en temptabell sätts databasen till tempdb.
	-- (det för att kunna läsa systemvyer och ta reda på columner, mm)
	--
	if @SourceDatabase is null and left(parsename(@SourceTable, 1), 1) = '#'
		set @SourceDatabase = quotename('tempdb')

	--
	-- Hjälpvariabler som lätt kan sprängas in i genererat merge-skript
	--
	declare @SQL_SourceDatabase varchar(512)
	set @SQL_SourceDatabase = isnull(@SourceDatabase + '.', '')


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


		,@SourceTable =
			isnull(quotename(parsename(@SourceTable, 3)) + '.', '')
			+ isnull(quotename(parsename(@SourceTable, 2)) + '.', '')
			+ quotename(parsename(@SourceTable, 1))

	--
	-- Kontrollera om källltabellen finns.
	--
	if object_id(@SourceTableFQN) is null
		raiserror ('Source table %s does not exists.', 16, 10, @SourceTable)


	--
	-- Fylls med information om källtabellen
	--
	create table #SourceColumns
	(
		name sysname
		,column_id int
		,user_type_id tinyint not null
		,max_length smallint not null
		,precision tinyint not null
		,scale tinyint not null
		,collation_name sysname null
		,is_nullable bit
	)

	select
		@SQL_Temp =
			'
			select
				name
				,column_id
				,user_type_id
				,max_length
				,precision
				,scale
				,collation_name
				,is_nullable
			from
				' + @SQL_SourceDatabase + 'sys.columns srcJoinCol
			where
				srcJoinCol.object_id = object_id(''' + @SourceTableFQN + ''')
			'

	insert into #SourceColumns
	exec (@SQL_Temp)

	--
	-- Verifiera att KeyColumnerna finns i källtabellen
	--
	set @Error = null
	select
		@Error = isnull(@Error + ', ', '') + keyCol.KeyColumns
	from
		#KeyColumns keyCol
			left join #SourceColumns srcCol on
				srcCol.name=  keyCol.KeyColumns
	where
		srcCol.column_id is null

	if len(@Error) > 0
		begin
			set @Error = 'Key columns ' + @Error + ' missing in source table ' + @SourceTable;
			raiserror(@Error, 16, 10)
			return;
		end

	--
	-- Mappningstabell sqls user_type_id -> FCObjectPropertyDatatype
	--
	select
		name
		,user_type_id
		,FCObjectPropertyDatatypeID =
			case
				when name in ('date', 'datetime', 'datetime2','smalldatetime', 'time') then 5 -- datetime
				when name in ('tinyint', 'smallint', 'int', 'bigint','real','money','float','decimal','numeric', 'smallmoney') then 4 -- float
				when name in ('bit') then 2 -- Bit
				when name in ('char', 'nchar', 'varchar', 'nvarchar', 'sysname', 'uniqueidentifier') then 1 -- String
				else -1
			end
	into
		#DataTypeMap
	from
		sys.types



	;with ObjectPropertyProperties as
	(
		--
		-- Properties konfigurerade i FCObjectProperty
		--
		select
			FCPropertyID = prop.ID
			,Name = prop.Name
			,prop.FCObjectPropertyDatatypeID
			,prop.isReadOnly
			,prop.isExternal
			,prop.isMandatory
			,prop.DefaultValue
			,TargetTable =
				case
					when prop.isObjectCode = 1 or prop.isObjectID = 1 or prop.isObjectName = 1 or prop.IsObjectParentID = 1 then
						-- Kolumnen sparas direkt i FCObject-tabell
						'FCObject'
					when prop.FCObjectPropertyControlID = 4 and nullif(prop.QueryToFillPredefinedValues, '') is null then
						-- En listkontroll utan dynamisk SQL, d.v.s. värdet finns i FCObjectPropertyPredefinedValue
						'FCObjectPropertyPredefinedValue'
					else
						-- Övriga värden sparas i
						'FCObjectPropertyValue'
				end
			,TargetColumn =
				case
					-- Obs! Vissa justeringar till detta görs senare beroende på TargetTable då exempelvis ValueDate inte finns i samtliga måltabell
					when prop.isObjectCode = 1 then 'Code'
					when prop.isObjectID = 1 then 'ID'
					when prop.isObjectName = 1 then 'Name'
					when prop.IsObjectParentID = 1 then 'ParentID'
					when prop.FCObjectPropertyDatatypeID in (2,3,4) then 'ValueNumeric'
					when prop.FCObjectPropertyDatatypeID in (5) then 'ValueDate'
					else 'ValueString'

				end
		from
			FCObjectProperty prop
		where
			prop.FCObjectTypeID = @FCObjectTypeID
	        and prop.IsDeleted = 0

	)
	,
	FCObjectColumns as
	(
		--
		-- Övriga bra kolumner från FCObject som inte finns refererade via FCObjectProperty
		--
		select
			FCPropertyID = null
			,Name =
				case
					when c.name in ('ID','isDeleted','isExternal') then 'FCObject' + upper(left(c.name,1)) + right(c.name, len(c.name) -1)
					else c.name
				end
			,FCObjectPropertyDatatypeID = typeMap.FCObjectPropertyDatatypeID
			,isReadOnly = 0
			,isExternal = 0
			,isMandatory = case when c.is_nullable = 0 and c.default_object_id = 0 then 1 else 0 end
			,DefaultValue = null
			,TargetTable = 'FCObject'
			,TargetColumn = c.name

		from
			sys.columns c
				inner join #DataTypeMap typeMap on
					typeMap.user_type_id = c.user_type_id
				--left join sys.default_constraints d on
				--	d.object_id = c.default_object_id
		where
			c.object_id = object_id('dbo.FCObject')
			and c.name not in
			(
				'FCObjectTypeID'
				--,'CreatedBy'
				--,'CreatedDate'
				--,'ModifiedBy'
				--,'ModifiedDate'
			)

	)
	,
	FCObjectElementColumns as
	(
		--
		-- Kolumner från FCObjectElemement
		--
		select
			FCPropertyID = null
			,Name =
				case
					when c.name = 'ElementKey' then 'FCObjectElementKey'
					else'FCObjectElement' + upper(left(c.name,1)) + right(c.name, len(c.name) -1)
				end
			,FCObjectPropertyDatatypeID = typeMap.FCObjectPropertyDatatypeID
			,isReadOnly = 0
			,isExternal = 0
			,isMandatory = case when c.is_nullable = 0 and c.default_object_id = 0 then 1 else 0 end
			,DefaultValue = null
			,TargetTable = 'FCObjectElement'
			,TargetColumn = c.name

		from
			sys.columns c
				inner join #DataTypeMap typeMap on
					typeMap.user_type_id = c.user_type_id
				--left join sys.default_constraints d on
				--	d.object_id = c.default_object_id
		where
			c.object_id = object_id('dbo.FCObjectElement')
			and @IsStandAlone = 0
			and c.name not in
			(
				'FCObjectID'
			)
	)
	,
	ObjectProperties as
	(
		--
		-- Sammanslagning av samtliga intressanta kolumner och properties
		--
		select
			FCPropertyID
			,Name
			,FCObjectPropertyDatatypeID
			,isReadOnly
			,isExternal
			,isMandatory = isnull(isMandatory, 0)
			,DefaultValue
			,TargetTable
			,TargetColumn =
				case -- Fix för ValueDate som inte finns i FCObjectPropertyPredefinedValue
					when TargetColumn = 'ValueDate' and TargetTable in ('FCObjectPropertyPredefinedValue') then
						'ValueString'
					else
						TargetColumn
				end
			,TableAlias =
				case
					when TargetTable = 'FCObject' then 'o'
					when TargetTable = 'FCObjectPropertyPredefinedValue' then 'pvp' + cast(FCPropertyID as varchar(12))
					when TargetTable = 'FCObjectPropertyValue' then 'pv' + cast(FCPropertyID as varchar(12))
				end
		from
			ObjectPropertyProperties
		union all
		select
			objCol.FCPropertyID
			,objCol.Name
			,FCObjectPropertyDatatypeID = objCol.FCObjectPropertyDatatypeID
			,objCol.isReadOnly
			,objCol.isExternal
			,isMandatory = isnull(objCol.isMandatory, 0)
			,objCol.DefaultValue
			,objCol.TargetTable
			,objCol.TargetColumn
			,TableAlias = 'o'
		from
			FCObjectColumns objCol
				left join ObjectPropertyProperties propCol on
					propCol.TargetTable = 'FCObject'
					and propCol.TargetColumn = objCol.TargetColumn
					and propCol.TargetColumn not in('ID', 'isDeleted','isExternal') -- Ta alltid med FCObjectID
		where
			propCol.FCPropertyID is null
		union all
		select
			FCPropertyID = null
			,Name = elementCol.Name
			,FCObjectPropertyDatatypeID = elementCol.FCObjectPropertyDatatypeID
			,isReadOnly = elementCol.isReadOnly
			,isExternal = elementCol.isExternal
			,isMandatory = isnull(elementCol.isMandatory, 0)
			,elementCol.DefaultValue
			,elementCol.TargetTable
			,elementCol.TargetColumn
			,TableAlias = 'oe'
		from
			FCObjectElementColumns elementCol
	)
	select

		ID = ROW_NUMBER() over (order by isnull(prop.FCPropertyID, 99999999))

		,prop.FCPropertyID
		,prop.Name
		,prop.TargetTable
		,prop.TargetColumn
		,TargetAlias = prop.TableAlias
		,TargetExpression = prop.TableAlias + '.' + quotename(prop.TargetColumn)
		,TargetValueExpression =
			case
				when tgtType.FCObjectPropertyDatatypeID <> dataType.ID then
					'cast('
					+ prop.TableAlias + '.' + quotename(prop.TargetColumn)
					+ ' as '
					+
					case
						when dataType.Name = 'string' then 'nvarchar(3000)'
						else dataType.Name
					end
					+ ')'
				else
					prop.TableAlias + '.' + quotename(prop.TargetColumn)
			end
		,ValueCastNeeded = case when tgtType.FCObjectPropertyDatatypeID <> dataType.ID then 1 else 0 end
		,TargetSQLTypeExpression =
			case
				when dataType.Name = 'string' then 'nvarchar(3000)'
				else dataType.Name
			end
		,ValueVariableName = '@Property' + isnull(cast(prop.FCPropertyID as nvarchar(500)), prop.TargetTable + '_' + prop.TargetColumn )+ '_Value'
		,IsKey = case when propKey.KeyColumns is not null then 1 else 0 end
		,prop.isMandatory
		,IsMatched =
			case
				when @Operation = 1 and
				(
					(@IsStandAlone = 1 and prop.Name = 'FCObjectIsDeleted')
					or
					(@IsStandAlone = 0 and prop.Name = 'FCObjectElementIsDeleted')
				) then
					1
				when srcCol.Name is null then
					0
				else
					1
			 end

		--,srcCol.name
	into #PropertyInfo
	From
		ObjectProperties prop
			inner join FCObjectPropertyDatatype dataType on
				dataType.ID = prop.FCObjectPropertyDatatypeID
			left join #KeyColumns propKey on
				propKey.KeyColumns = prop.Name
			left join #SourceColumns srcCol on
				srcCol.name = prop.Name
			left join sys.columns tgtCol on
				tgtCol.object_id = object_id(prop.TargetTable)
				and tgtCol.name = prop.TargetColumn
			left join #DataTypeMap tgtType on
				tgtType.user_type_id = tgtCol.user_type_id

	--
	-- Verifiera att KeyColumnerna finns i destinationstabellen
	--
	set @Error = null
	select
		@Error = isnull(@Error + ', ', '') + keyCol.KeyColumns
	from
		#KeyColumns keyCol
			left join #PropertyInfo propCol on
				propCol.Name=  keyCol.KeyColumns
	where
		propCol.ID is null

	if len(@Error) > 0
		begin
			set @Error = 'Key columns ' + @Error + ' missing in FCObject / FCObjectProperty.';
			raiserror(@Error, 16, 10)
			return;
		end

	if not exists(select 1 from #PropertyInfo where IsMatched = 1)
		begin
			set @Error = 'No column in source table matches properties in FCObject' ;
			raiserror(@Error, 16, 10)
			return;
		end


	set @Error = null
	select
		@Error = isnull(@Error + ', ', '') + propCol.Name
	from
		#PropertyInfo propCol
	where
		propCol.isMandatory = 1 and IsMatched = 0
		and propCol.Name not in
		(
			'FCObjectID', 'CreatedBy', 'CreatedDate', 'FCObjectElementModifiedBy', 'FCObjectElementID'
		)

	if len(@Error) > 0
		begin
			set @Error = 'Mandatory properties ' + @Error + ' are missing in in source table ' + @SourceTable;
			raiserror(@Error, 16, 10)
			return;
		end



	set @SQL_Temp = 'select' + @NewLine
	select
		@SQL_Temp = @SQL_Temp
			+ '	' + case when row_number() over (order by p.ID) = 1 then '' else ',' end
			+ quotename(p.name) + ' = ' +
				case
					when p.TargetColumn in ('isDeleted','isExternal') then
						'isnull(' + TargetValueExpression + ',0)'
					else
						p.TargetValueExpression
				end + @NewLine
	from
		#PropertyInfo p
	where
		p.IsMatched = 1
		or (p.TargetTable = 'FCObject' and p.TargetColumn in('ID', 'isDeleted','isExternal')) -- FCObjectID ska alltid finnas med

	select
		@SQL_Temp = @SQL_Temp
			+ 'from' + @NewLine
			+ '	dbo.FCObject o' + @NewLine

	if exists(select 1 from FCObjectType t where t.ID = @FCObjectTypeID and t.IsStandAlone = 0)
		select 	@SQL_Temp = @SQL_Temp +
					'		inner join dbo.FCObjectElement oe on' + @NewLine
					+ '			oe.FCObjectID = o.ID' + @NewLine

	select
		@SQL_Temp = @SQL_Temp +
			case
				when p.TargetTable = 'FCObjectPropertyValue' then
					'		left join dbo.' + p.TargetTable + ' ' + p.TargetAlias + ' on' + @NewLine
					+ '			' + p.TargetAlias + '.FCObjectID = o.ID' + @NewLine
					+ '			and ' + p.TargetAlias + '.FCObjectPropertyID = ' + cast(p.FCPropertyID as nvarchar(12)) + @NewLine
				when p.TargetTable = 'FCObjectPropertyPredefinedValue' then
					+ '		left join dbo.FCObjectPropertyValue pv_' + p.TargetAlias + ' on' + @NewLine
					+ '			pv_' + p.TargetAlias + '.FCObjectID = o.ID' + @NewLine
					+ '			and pv_' + p.TargetAlias + '.FCObjectPropertyID = ' + cast(p.FCPropertyID as nvarchar(12)) + @NewLine
					+ '		left join ' + p.TargetTable + ' ' + p.TargetAlias + ' on' + @NewLine
					+ '			' + p.TargetAlias + '.ID = pv_' + p.TargetAlias + '.FCObjectPropertyPredefinedValueID' + @NewLine
					+ '			and ' + p.TargetAlias + '.FCObjectPropertyID = ' + cast(p.FCPropertyID as nvarchar(12)) + @NewLine
			end
	from
		#PropertyInfo p
	where
		p.IsMatched = 1
		and p.TargetTable in ('FCObjectPropertyValue', 'FCObjectPropertyPredefinedValue')

	select @SQL_Temp = @SQL_Temp +
		'where' + @NewLine
		+ '	o.FCObjectTypeID = ' + cast(@FCObjectTypeID as nvarchar(12)) + @NewLine

	declare @SQL_Merge nvarchar(max)
	declare @FirstMatchedKeyProperty int
	select
		@FirstMatchedKeyProperty = min(ID)
	from
		#PropertyInfo p
	where
		p.IsMatched = 1
		and p.IsKey = 1
	select
		@SQL_Merge =
			';with DestData as' + @NewLine
			+ '(' + @NewLine
			+ @SQL_Temp
			+ ')' + @NewLine
			+ ',' + @NewLine
			+ 'SourceData as' + @NewLine
			+ '(' + @NewLine
			+ '	select' + @NewLine

			+	(
					select
						'		' + case when row_number() over (order by column_id) > 1 then ',' else '' end
						+ quotename(name) + @NewLine
					from
						#SourceColumns
					order by
						column_id
					for xml path(''), type
				).value('.','nvarchar(max)')
			+
			case
				when @Operation = 1 and @IsStandAlone = 1 and not exists(select 1 from #SourceColumns where name = 'FCObjectIsDeleted') then
					'		,FCObjectIsDeleted = 0' + @NewLine
				when @Operation = 1 and @IsStandAlone = 0 and not exists(select 1 from #SourceColumns where name = 'FCObjectElementIsDeleted') then
					'		,FCObjectElementIsDeleted = 0' + @NewLine
				else
					''
			end
			+ '	From' + @NewLine
			+ '		' + @SourceTable + @NewLine
			+ ')' + @NewLine
			+ 'select' + @NewLine
			+ '	__SYNC_DEST_OBJ_ID__ = dest.FCObjectID' + @NewLine
			+ '	,__SYNC_ACTION__ = '

	if @FirstMatchedKeyProperty is not null
		select
			@SQL_Merge = @SQL_Merge + @NewLine
				+ '		case' + @NewLine
				+ '			when src.' + quotename(p.Name) + ' is null then ''D''' + @NewLine
				+ '			when dest.' + quotename(p.Name) + ' is null then ''I'' ' + @NewLine
				+ '			else ''U''' + @NewLine
				+ '		end' + @NewLine
		from
			#PropertyInfo p
		where
			ID = @FirstMatchedKeyProperty
	else
		select
			@SQL_Merge = @SQL_Merge +
				'''I''' + @NewLine -- Om ingen matchad nyckelkolumn finns blir det bara INSERT

	select @SQL_Merge = @SQL_Merge +
			+ '	,src.*' + @NewLine
			+ 'into #SyncAction' + @NewLine
			+ 'from' + @NewLine
			+ '	SourceData src' + @NewLine +
			case
				when @Operation in (3,4) then -- Operation 4 behöver egentligen ingen join till DestData men det blev enklare så här.
					'		left join DestData dest on'
				else
					'		full join DestData dest on'
			end + @NewLine
	select
		@SQL_Merge = @SQL_Merge + '			'
			+ case when row_number() over (order by p.ID) > 1 then 'and ' else '' end
			+ 'src.' + quotename(p.Name) + ' = dest.' + quotename(p.Name) + @NewLine
	from
		#PropertyInfo p
	where
		p.IsMatched = 1
		and p.IsKey = 1
		and @Operation <> 4
	order by
		p.ID

	if @@ROWCOUNT = 0
		select
			@SQL_Merge = @SQL_Merge + '			1=0' + @NewLine

	if @FirstMatchedKeyProperty is not null
		begin
			select @SQL_Merge = @SQL_Merge
				+ 'where' + @NewLine
				+'	(' + @NewLine +
				+ '		src.' + quotename(p.Name) + ' is null' + @NewLine
				+ '		or dest.' + quotename(p.Name) + ' is null' + @NewLine
			from
				#PropertyInfo p
			where
				p.ID = @FirstMatchedKeyProperty

			declare @SQL_ChangeCheck nvarchar(max)

			declare @SQL_ChangeCheck_SrcCols nvarchar(max)
			declare @SQL_ChangeCheck_DestCols nvarchar(max)

			--exists(select t1.col1, t1.col2 except select t2.col1, t2.col2)

			select
				@SQL_ChangeCheck_SrcCols = isnull(@SQL_ChangeCheck_SrcCols + ', ', '')
					+ 'src.' + quotename(p.name)
				,@SQL_ChangeCheck_DestCols = isnull(@SQL_ChangeCheck_DestCols + ', ', '')
					+ 'dest.' + quotename(p.name)

			from
				#PropertyInfo p
			where
				p.IsMatched = 1
				and p.IsKey = 0

			if len(@SQL_ChangeCheck_SrcCols) > 0
				select @SQL_Merge = @SQL_Merge
					+ '		or exists(select '+ @SQL_ChangeCheck_SrcCols + ' except select '+ @SQL_ChangeCheck_DestCols + ')' + @NewLine

			select @SQL_Merge = @SQL_Merge +
				'	)' + @NewLine

			if @Operation = 1
				begin
					-- Exkludera rader som är markerade som borttagna och fortfarande är borttagna.
					select @SQL_Merge = @SQL_Merge +
						'	and not' + @NewLine +
						'	(' + @NewLine +
						case when @IsStandAlone = 1 then -- Om StandAlone = false så markeras borttag i FCObjectElement annars i i FCObject
						'		(src.' + quotename(p.Name) + ' is null and isnull(dest.[FCObjectIsDeleted], 0) = 1)'
						else
						'		(src.' + quotename(p.Name) + ' is null and isnull(dest.[FCObjectElementIsDeleted], 0) = 1)'
						end + @NewLine +
						'	)' + @NewLine
					from
						#PropertyInfo p
					where
						p.ID = @FirstMatchedKeyProperty
				end



			--select
			--	@SQL_ChangeCheck = isnull(@SQL_ChangeCheck, '') + '		'
			--		+ case when row_number() over (order by p.ID) > 1 then 'and ' else '' end
			--		+ '(src.' + quotename(p.name) + ' = dest.' + quotename(p.name) + ' or (src.' +  quotename(p.name) + ' is null and dest.' + quotename(p.name) + ' is null))' + @NewLine
			--from
			--	#PropertyInfo p
			--where
			--	p.IsMatched = 1
			--	and p.IsKey = 0

			--order by
			--	p.ID

			--if @SQL_ChangeCheck is not null
			--	select @SQL_Merge = @SQL_Merge
			--		+ '	or not' + @NewLine
			--		+ '	(' + @NewLine
			--		+ @SQL_ChangeCheck
			--		+ '	)' + @NewLine
		end

	select @SQL_Merge = @SQL_Merge + 'option (force order)' + @NewLine
	select @SQL_Merge = @SQL_Merge + @NewLine
		+ 'declare' + @NewLine
		+ '	@FCObjectID int' + @NewLine
	select @SQL_Merge = @SQL_Merge + '	,'
		+ ValueVariableName + ' ' + p.TargetSQLTypeExpression + @NewLine
	from
		#PropertyInfo p
	where
		p.IsMatched = 1


	declare @SQL_InsertCursorFetch nvarchar(max)
	select @SQL_InsertCursorFetch =
		'FETCH NEXT FROM InsertCursor INTO' + @NewLine
	select @SQL_InsertCursorFetch = @SQL_InsertCursorFetch + '	'
		+ case when row_number() over (order by p.ID) > 1 then ',' else '' end
		+ p.ValueVariableName + @NewLine
	from
		#PropertyInfo p
	where
		p.IsMatched = 1


	select @SQL_Merge = @SQL_Merge + @NewLine
		+ 'DECLARE InsertCursor CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY  FOR' + @NewLine
		+ '	select' + @NewLine

	select @SQL_Merge = @SQL_Merge + '		'
		+ case when row_number() over (order by p.ID) > 1 then ',' else '' end
		+ quotename(p.name) + @NewLine
	from
		#PropertyInfo p
	where
		p.IsMatched = 1
	select @SQL_Merge = @SQL_Merge
		+ '	from' + @NewLine
		+ '		#SyncAction' + @NewLine
		+ '	where' + @NewLine
		+ '		__SYNC_ACTION__ = ''I''' + @NewLine
		+ '' + @NewLine
		--+ 'begin tran' + @NewLine
		+ 'OPEN InsertCursor' + @NewLine
		+ '' + @NewLine
		+ @SQL_InsertCursorFetch + @NewLine
		+ 'WHILE @@FETCH_STATUS = 0' + @NewLine
		+ 'BEGIN' + @NewLine



	select @SQL_Merge = @SQL_Merge
		+ '	insert into dbo.FCObject' + @NewLine
		+ '	(' + @NewLine
		+ '		[FCObjectTypeID]' + @NewLine
	select @SQL_Merge = @SQL_Merge + '		,'
		+ quotename(p.TargetColumn) + @NewLine
	from
		#PropertyInfo p
	where
		(
			p.IsMatched = 1
			or p.TargetColumn in
			(
				'CreatedBy'
				,'CreatedDate'
			)
		)
		and p.TargetTable = 'FCObject'
		and p.TargetColumn <> 'ID'
	order by
		p.ID

	select @SQL_Merge = @SQL_Merge
		+ '	)' + @NewLine
		+ '	values' + @NewLine
		+ '	(' + @NewLine
		+ '		' + +cast(@FCObjectTypeID as nvarchar(12)) + @NewLine
	select @SQL_Merge = @SQL_Merge + '		,'
		+ case
			when p.IsMatched = 1 then
				p.ValueVariableName
			when p.TargetColumn = 'CreatedBy' then
				@ChangeUserCasted
			when p.TargetColumn = 'CreatedDate' then
				'getutcdate()'
			end + @NewLine
	from
		#PropertyInfo p
	where
		(
			p.IsMatched = 1
			or p.TargetColumn in
			(
				'CreatedBy'
				,'CreatedDate'
			)
		)
		and p.TargetTable = 'FCObject'
		and p.TargetColumn <> 'ID'
	order by
		p.ID

	select @SQL_Merge = @SQL_Merge
		+ '	)' + @NewLine
		+ '	select @FCObjectID = SCOPE_IDENTITY();' + @NewLine






	if exists(select 1 from #PropertyInfo p where IsMatched = 1 and TargetTable in ('FCObjectElement'))
		begin

			select @SQL_Merge = @SQL_Merge
				+ '	insert into dbo.FCObjectElement' + @NewLine
				+ '	(' + @NewLine
				+ '		[FCObjectID]' + @NewLine
			select @SQL_Merge = @SQL_Merge + '		,'
				+ quotename(p.TargetColumn) + @NewLine
			from
				#PropertyInfo p
			where
				(
					p.IsMatched = 1
					or p.TargetColumn in
					(
						'ModifiedBy'
						,'ModifiedDate'
					)
				)
				and p.TargetTable = 'FCObjectElement'
				and p.TargetColumn <> 'ID'
			order by
				p.ID

			select @SQL_Merge = @SQL_Merge
				+ '	)' + @NewLine
				+ '	values' + @NewLine
				+ '	(' + @NewLine
				+ '		@FCObjectID' + @NewLine
			select @SQL_Merge = @SQL_Merge + '		,'
				+ case
					when p.IsMatched = 1 then
						p.ValueVariableName
					when p.TargetColumn = 'ModifiedBy' then
						@ChangeUserCasted
					when p.TargetColumn = 'ModifiedDate' then
						'getutcdate()'
					end + @NewLine
			from
				#PropertyInfo p
			where
				(
					p.IsMatched = 1
					or p.TargetColumn in
					(
						'ModifiedBy'
						,'ModifiedDate'
					)
				)
				and p.TargetTable = 'FCObjectElement'
				and p.TargetColumn <> 'ID'
			order by
				p.ID

			select @SQL_Merge = @SQL_Merge
				+ '	)' + @NewLine
		end






	if exists(select 1 from #PropertyInfo p where IsMatched = 1 and TargetTable in ('FCObjectPropertyValue','FCObjectPropertyPredefinedValue'))
		begin
			select @SQL_Merge = @SQL_Merge + @NewLine
				+ '	insert into dbo.FCObjectPropertyValue' + @NewLine
				+ '	(' + @NewLine
				+ '		[FCObjectID]' + @NewLine
				+ '		,[FCObjectPropertyID]' + @NewLine
				+ '		,[ValueNumeric]' + @NewLine
				+ '		,[ValueString]' + @NewLine
				+ '		,[ValueDate]' + @NewLine
				+ '		,[FCObjectPropertyPredefinedValueID]' + @NewLine
				+ '		,[ModifiedBy]' + @NewLine
				+ '		,[ModifedDate]' + @NewLine
				+ '	)' + @NewLine

				--@ChangeUser
			select @SQL_Merge = @SQL_Merge + '	'
				+ case when row_number() over (order by p.ID) > 1 then 'union all ' else '' end
				+ 'select' + @NewLine +
				+ '		[FCObjectID] = @FCObjectID' + @NewLine
				+ '		,[FCObjectPropertyID] = ' + cast(p.FCPropertyID as nvarchar(12))+ @NewLine
				+ '		,[ValueNumeric] = ' +
					case
						when p.TargetTable = 'FCObjectPropertyValue' and p.TargetColumn = 'ValueNumeric' then
							p.ValueVariableName
						else
							'NULL'
					end + @NewLine
				+ '		,[ValueString] = ' +
					case
						when p.TargetTable = 'FCObjectPropertyValue' and p.TargetColumn = 'ValueString' then
							p.ValueVariableName
						else
							'NULL'
					end + @NewLine
				+ '		,[ValueDate] = ' +
					case
						when p.TargetTable = 'FCObjectPropertyValue' and p.TargetColumn = 'ValueDate' then
							p.ValueVariableName
						else
							'NULL'
					end + @NewLine
				+ '		,[FCObjectPropertyPredefinedValueID] = ' +
					case
						when p.TargetTable = 'FCObjectPropertyPredefinedValue' then
							'(select ID from FCObjectPropertyPredefinedValue where FCObjectPropertyID = ' + cast(p.FCPropertyID as nvarchar(12)) + ' and ValueNumeric = ' + p.ValueVariableName + ')'
						else
							'NULL'
					end + @NewLine
				+ '		,[ModifiedBy] = ' + @ChangeUserCasted + @NewLine
				+ '		,[ModifedDate] = getutcdate()' + @NewLine
			from
				#PropertyInfo p
			where
				p.IsMatched = 1
				and p.TargetTable in ('FCObjectPropertyValue','FCObjectPropertyPredefinedValue')
		end

	select @SQL_Merge = @SQL_Merge
		+ @SQL_InsertCursorFetch + @NewLine
		+ 'END' + @NewLine


	if @Operation <> 4 -- Allt utom Operation 4 ska hantera update
		begin
			select @SQL_Merge = @SQL_Merge + @NewLine +
				+ 'update o set'+ @NewLine

			select @SQL_Merge = @SQL_Merge + '		' + case when row_number() over (order by ID) > 1 then ',' else '' end
				+ quotename(p.TargetColumn) + ' = '  +
					case
						when p.ValueCastNeeded = 1 then
							'cast('
						else
							''
					end +
					case
						when p.IsMatched = 1 then
							's.' + quotename(p.Name)
						when p.TargetColumn = 'ModifiedBy' then
							@ChangeUserCasted
						when p.TargetColumn = 'ModifiedDate' then
							'getutcdate()'
					end +
					case
						when p.ValueCastNeeded = 1 then
							 ' as ' + p.TargetSQLTypeExpression + ')'
						else
							''
					end + @NewLine
			from
				#PropertyInfo p
			where
				(
					p.IsMatched = 1
					or p.TargetColumn in
					(
						'ModifiedBy'
						,'ModifiedDate'
					)
				)
				and p.TargetTable = 'FCObject'
				and p.TargetColumn <> 'ID'
			order by
				p.ID

			select @SQL_Merge = @SQL_Merge +
				+ 'from'+ @NewLine
				+ '	#SyncAction s'+ @NewLine
				+ '		inner join dbo.FCObject o on'+ @NewLine
				+ '			o.ID = s.__SYNC_DEST_OBJ_ID__ '+ @NewLine
				+ 'where'+ @NewLine
				+ '	s.__SYNC_ACTION__ = ''U'''+ @NewLine


			if exists(select 1 from #PropertyInfo p where IsMatched = 1 and TargetTable in ('FCObjectElement'))
				begin
					select @SQL_Merge = @SQL_Merge + @NewLine +
						+ 'update o set'+ @NewLine

					select @SQL_Merge = @SQL_Merge + '		' + case when row_number() over (order by ID) > 1 then ',' else '' end
						+ quotename(p.TargetColumn) + ' = '  +
							case
								when p.IsMatched = 1 then
									's.' + quotename(p.Name)
								when p.TargetColumn = 'ModifiedBy' then
									@ChangeUserCasted
								when p.TargetColumn = 'ModifiedDate' then
									'getutcdate()'
							end + @NewLine

					from
						#PropertyInfo p
					where
						(
							p.IsMatched = 1
							or p.TargetColumn in
							(
								'ModifiedBy'
								,'ModifiedDate'
							)
						)
						and p.TargetTable = 'FCObjectElement'
						and p.TargetColumn <> 'ID'
					order by
						p.ID

					select @SQL_Merge = @SQL_Merge +
						+ 'from'+ @NewLine
						+ '	#SyncAction s'+ @NewLine
						+ '		inner join dbo.FCObjectElement o on'+ @NewLine
						+ '			o.FCObjectID = s.__SYNC_DEST_OBJ_ID__ '+ @NewLine
						+ 'where'+ @NewLine
						+ '	s.__SYNC_ACTION__ = ''U'''+ @NewLine

				end


			if exists(select 1 from #PropertyInfo p where
				p.IsMatched = 1
				and p.TargetTable in ('FCObjectPropertyValue','FCObjectPropertyPredefinedValue'))
				begin
					select @SQL_Merge = @SQL_Merge + @NewLine
						+ ';with MatchedProperties as' + @NewLine
						+ '(' + @NewLine

					select @SQL_Merge = @SQL_Merge + '	' +  case when row_number() over (order by ID) > 1 then 'union all ' else '' end
						+ 'select FCObjectPropertyID = ' + cast(p.FCPropertyID as nvarchar(12)) + @NewLine
						--+ ' ,TargetTable = ''' + p.TargetTable + ''''
						--+ ' ,TargetColumn = ''' + p.TargetColumn + '''' + @NewLine
					from
						#PropertyInfo p
					where
						p.IsMatched = 1
						and p.TargetTable in ('FCObjectPropertyValue','FCObjectPropertyPredefinedValue')
					order by
						p.ID

					select @SQL_Merge = @SQL_Merge + @NewLine
						+ ')' + @NewLine
						+ ',PropertyData as' + @NewLine
						+ '(' + @NewLine
						+ '	select' + @NewLine
						+ '		PropertyValueID = pv.ID' + @NewLine
						+ '		,FCObjectID = s.__SYNC_DEST_OBJ_ID__' + @NewLine
						+ '		,FCObjectPropertyID = mp.FCObjectPropertyID' + @NewLine
						+'		,ValueNumeric =' +
							isnull
							(
								@NewLine + '			'
								+ 'case mp.FCObjectPropertyID' + @NewLine +
								(
									select
										'				when ' + cast(FCPropertyID as nvarchar(12)) + ' then s.' + quotename(Name) + @NewLine
									from
										#PropertyInfo
									where
										IsMatched = 1
										and TargetTable = 'FCObjectPropertyValue'
										and TargetColumn = 'ValueNumeric'
									for xml path(''), type
								).value('.','nvarchar(max)')
								+'			end'
								,
								'NULL'
							) + @NewLine
						+'		,ValueString =' +
							isnull
							(
								@NewLine + '			'
								+ 'case mp.FCObjectPropertyID' + @NewLine +
								(
									select
										'				when ' + cast(FCPropertyID as nvarchar(12)) + ' then s.' + quotename(Name) + @NewLine
									from
										#PropertyInfo
									where
										IsMatched = 1
										and TargetTable = 'FCObjectPropertyValue'
										and TargetColumn = 'ValueString'
									for xml path(''), type
								).value('.','nvarchar(max)')
								+'			end'
								,
								'NULL'
							) + @NewLine
						+'		,ValueDate =' +
							isnull
							(
								@NewLine + '			'
								+ 'case mp.FCObjectPropertyID' + @NewLine +
								(
									select
										'				when ' + cast(FCPropertyID as nvarchar(12)) + ' then s.' + quotename(Name) + @NewLine
									from
										#PropertyInfo
									where
										IsMatched = 1
										and TargetTable = 'FCObjectPropertyValue'
										and TargetColumn = 'ValueDate'
									for xml path(''), type
								).value('.','nvarchar(max)')
								+'			end'
								,
								'NULL'
							) + @NewLine
					--	+'		,FCObjectPropertyPredefinedValueID = null' +  @NewLine
						+'		,FCObjectPropertyPredefinedValueNumeric = ' +
							isnull
							(
								@NewLine + '			'
								+ 'case mp.FCObjectPropertyID' + @NewLine +
								(
									select
										'				when ' + cast(FCPropertyID as nvarchar(12)) + ' then s.' + quotename(Name) + @NewLine
									from
										#PropertyInfo
									where
										IsMatched = 1
										and TargetTable = 'FCObjectPropertyPredefinedValue'
										and TargetColumn = 'ValueNumeric'
									for xml path(''), type
								).value('.','nvarchar(max)')
								+'			end'
								,
								'NULL'
							) + @NewLine
						+'		,FCObjectPropertyPredefinedValueString = ' +
							isnull
							(
								@NewLine + '			'
								+ 'case mp.FCObjectPropertyID' + @NewLine +
								(
									select
										'				when ' + cast(FCPropertyID as nvarchar(12)) + ' then s.' + quotename(Name) + @NewLine
									from
										#PropertyInfo
									where
										IsMatched = 1
										and TargetTable = 'FCObjectPropertyPredefinedValue'
										and TargetColumn = 'ValueString'
									for xml path(''), type
								).value('.','nvarchar(max)')
								+'			end'
								,
								'NULL'
							) + @NewLine
						+'	from' + @NewLine
						+'		#SyncAction s' + @NewLine
						+'			cross join MatchedProperties mp' + @NewLine
						+'			left join dbo.FCObjectPropertyValue pv on' + @NewLine
						+'				pv.FCObjectID = s.__SYNC_DEST_OBJ_ID__ ' + @NewLine
						+'				and pv.FCObjectPropertyID = mp.FCObjectPropertyID' + @NewLine
						+'	where' + @NewLine
						+'		s.__SYNC_ACTION__ = ''U''' + @NewLine
						+')' + @NewLine
						+'select' + @NewLine
						+'	d.*' + @NewLine
						+'	,FCObjectPropertyPredefinedValueID = pdv.ID' + @NewLine
						+'into #SyncPropertyValue' + @NewLine
						+'from' + @NewLine
						+'	PropertyData d' + @NewLine
						+'		left join FCObjectPropertyPredefinedValue pdv on' + @NewLine
						+'			pdv.FCObjectPropertyID = d.FCObjectPropertyID' + @NewLine
						+'			and ' + @NewLine
						+'			(' + @NewLine
						+'				pdv.ValueString = d.FCObjectPropertyPredefinedValueString' + @NewLine
						+'				or pdv.ValueNumeric = d.FCObjectPropertyPredefinedValueNumeric' + @NewLine
						+'			)' + @NewLine
						+ @NewLine




						+'update dest set' + @NewLine
						+'	ValueNumeric = src.ValueNumeric' + @NewLine
						+'	,ValueString = src.ValueString' + @NewLine
						+'	,ValueDate = src.ValueDate' + @NewLine
						+'	,FCObjectPropertyPredefinedValueID = src.FCObjectPropertyPredefinedValueID' + @NewLine
						+'	,ModifiedBy = ' + @ChangeUserCasted + @NewLine
						+'	,ModifedDate = getutcdate()' + @NewLine
						+'from' + @NewLine
						+'	#SyncPropertyValue src' + @NewLine
						+'		inner join FCObjectPropertyValue dest on' + @NewLine
						+'			dest.ID = src.PropertyValueID' + @NewLine
						+'where' + @NewLine
						+'	exists(select src.ValueNumeric, src.ValueString, src.ValueDate, src.FCObjectPropertyPredefinedValueID except select dest.ValueNumeric, dest.ValueString, dest.ValueDate, dest.FCObjectPropertyPredefinedValueID)' + @NewLine
						--+'	not' + @NewLine
						--+'	(' + @NewLine
						--+'		(src.ValueNumeric = dest.ValueNumeric or (src.ValueNumeric is null and dest.ValueNumeric is null))' + @NewLine
						--+'		and (src.ValueString = dest.ValueString or (src.ValueString is null and dest.ValueString is null))' + @NewLine
						--+'		and (src.ValueDate = dest.ValueDate or (src.ValueDate is null and dest.ValueDate is null))' + @NewLine
						--+'		and (src.FCObjectPropertyPredefinedValueID = dest.FCObjectPropertyPredefinedValueID or (src.FCObjectPropertyPredefinedValueID is null and dest.FCObjectPropertyPredefinedValueID is null))' + @NewLine
						--+'	)' + @NewLine
						+ @NewLine
						+'insert into dbo.FCObjectPropertyValue' + @NewLine
						+'(' + @NewLine
						+'	[FCObjectID]' + @NewLine
						+'	,[FCObjectPropertyID]' + @NewLine
						+'	,[ValueNumeric]' + @NewLine
						+'	,[ValueString]' + @NewLine
						+'	,[ValueDate]' + @NewLine
						+'	,[FCObjectPropertyPredefinedValueID]' + @NewLine
						+'	,[ModifiedBy]' + @NewLine
						+'	,[ModifedDate]' + @NewLine
						+')' + @NewLine
						+'select' + @NewLine
						+'	[FCObjectID] = src.FCObjectID' + @NewLine
						+'	,[FCObjectPropertyID] = src.FCObjectPropertyID' + @NewLine
						+'	,[ValueNumeric] = src.ValueNumeric' + @NewLine
						+'	,[ValueString] = src.ValueString' + @NewLine
						+'	,[ValueDate] = src.ValueDate' + @NewLine
						+'	,[FCObjectPropertyPredefinedValueID] = src.FCObjectPropertyPredefinedValueID' + @NewLine
						+'	,[ModifiedBy] = ' + @ChangeUserCasted + @NewLine
						+'	,[ModifedDate] = getutcdate()' + @NewLine
						+'from' + @NewLine
						+'	#SyncPropertyValue src' + @NewLine
						+'where' + @NewLine
						+'	src.PropertyValueID is null' + @NewLine
						+ @NewLine
				end

			if @Operation = 1
				begin
					if @IsStandAlone = 1
						--
						-- Borttag vid Stand Alone markeras i FCObject
						--
						select @SQL_Merge = @SQL_Merge + @NewLine
							+ 'update o set' + @NewLine +
							+ '	isDeleted = 1' + @NewLine +
							+ 'from' + @NewLine
							+ '	dbo.FCObject o' + @NewLine
							+ '		inner join #SyncAction s on' + @NewLine
							+ '			s.__SYNC_DEST_OBJ_ID__ = o.ID' + @NewLine
							+ 'where' + @NewLine
							+ '	(o.IsDeleted = 0 or o.IsDeleted is null)' + @NewLine
							+ '	and s.__SYNC_ACTION__ = ''D''' + @NewLine
					else
						--
						-- Borttag vid Element-koppling markeras i FCObjectElement
						--
						select @SQL_Merge = @SQL_Merge + @NewLine
							+ 'update o set' + @NewLine +
							+ '	isDeleted = 1' + @NewLine +
							+ 'from' + @NewLine
							+ '	dbo.FCObjectElement o' + @NewLine
							+ '		inner join #SyncAction s on' + @NewLine
							+ '			s.__SYNC_DEST_OBJ_ID__ = o.FCObjectID' + @NewLine
							+ 'where' + @NewLine
							+ '	(o.IsDeleted = 0 or o.IsDeleted is null)' + @NewLine
							+ '	and s.__SYNC_ACTION__ = ''D''' + @NewLine
				end
			else if @Operation = 2
				begin
					select @SQL_Merge = @SQL_Merge + @NewLine
						+ 'delete pv' + @NewLine +
						+ 'from' + @NewLine
						+ '	dbo.FCObjectPropertyValue pv'
						+ '		inner join #SyncAction s on' + @NewLine
						+ '			s.__SYNC_DEST_OBJ_ID__ = pv.FCObjectID' + @NewLine
						+ 'where' + @NewLine
						+ '	s.__SYNC_ACTION__ = ''D''' + @NewLine
						+ @NewLine
						+ 'delete o' + @NewLine +
						+ 'from' + @NewLine
						+ '	dbo.FCObject o'
						+ '		inner join #SyncAction s on' + @NewLine
						+ '			s.__SYNC_DEST_OBJ_ID__ = o.ID' + @NewLine
						+ 'where' + @NewLine
						+ '	s.__SYNC_ACTION__ = ''D''' + @NewLine
				end
			end
	--select @SQL_Merge = @SQL_Merge + @NewLine
		--+'commit tran' + @NewLine

	if @Debug = 0
		begin
			if @TranCount = 0 begin tran
			exec (@SQL_Merge)
			if @TranCount = 0 commit tran
		end
	else
		begin
			declare @str nvarchar(max)
			set @str = @SQL_Merge

			if (@str is not null and 1=1)
				begin


					-- This procedure was created to properly print
					-- nvarchar(max) since the print statement can
					-- only handle NVARCHAR(4000), we break the
					-- input down into 4000 byte blocks and print
					-- upto the last linebreak before the 4000 byte cutoff
					declare
	 					 @ReversedData nvarchar(max)
						,@LineBreakIndex int
						,@SearchLength int

					-- if the search length is less than the first occurance
					-- of a line break, the data will be printed with a line break
					-- at the SearchLength position even though there should not be
					-- a break in the data there.
					set @SearchLength = 4000

					-- only loop while the input is greater than the search length
					while len(@str) > @SearchLength
						begin
							-- obtain and reverse the input upto the search length
							set @ReversedData = reverse(left(@str, @SearchLength))

							-- determine the position of the first line break for this piece of data
							set @LineBreakIndex = charindex(char(10) + char(13), @ReversedData)

							-- print the input only showing data upto the line break
							-- the original linebreak will not be displayed
							print left(@str, @SearchLength - @LineBreakIndex + 1)

							-- resize the input removing the data that was displayed and the line break.
							set @str = right(@str, len(@str) - @SearchLength + @LineBreakIndex - 1)
						end

					-- if there is any data remaining, print it
					if len(@str) > 0
						print @str
				end
		end
	--print @SQL_Merge

	drop table #SourceColumns
	drop table #KeyColumns
	drop table #DataTypeMap
	drop table #PropertyInfo

end try

begin catch
	--
	-- Rollback transactions
	--
	while @TranCount = 0 and @@trancount > 0 rollback tran


	declare
		@ErrorMessage    nvarchar(4000),
		@ErrorNumber     int,
		@ErrorSeverity   int,
		@ErrorState      int,
		@ErrorLine       int,
		@ErrorProcedure  nvarchar(200);

	-- Assign variables to error-handling functions that
	-- capture information for RAISERROR.
	select
		@ErrorNumber = error_number(),
		@ErrorSeverity = error_severity(),
		@ErrorState = error_state(),
		@ErrorLine = error_line(),
		@ErrorProcedure = isnull(error_procedure(), '-');

	-- Build the message string that will contain original
	-- error information.
	select @ErrorMessage =
		N'Error %d, Level %d, State %d, Procedure %s, Line %d, ' +
			'Message: '+ error_message();

	-- Raise an error: msg_str parameter of RAISERROR will contain
	-- the original error information.
	raiserror
		(
		@ErrorMessage,
		@ErrorSeverity,
		1,
		@ErrorNumber,    -- parameter: original error number.
		@ErrorSeverity,  -- parameter: original error severity.
		@ErrorState,     -- parameter: original error state.
		@ErrorProcedure, -- parameter: original error procedure name.
		@ErrorLine       -- parameter: original error line number.
		);

	return -1
end catch

GO
