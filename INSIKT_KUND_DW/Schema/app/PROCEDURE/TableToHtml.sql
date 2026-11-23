SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[TableToHtml]
(
	@SourceTable  nvarchar(500)
	,@TableCssClass nvarchar(150) = null
	,@HtmlTable nvarchar(max) output
	,@OrderBy nvarchar(max) = null
)
as
--declare 
--	@SourceTable sysname = '#Tab'
--	,@TableCssClass nvarchar(150)= 'test'

--declare @HtmlTable nvarchar(max)
	
	--
	-- @SourceTableFQN och @TargetTableFQN innhåller databas, schema och namn på ett sådant sätt att object_id(...) returnerar rätt objekt.
	--
	declare @SourceTableFQN sysname
	
	declare @SourceDatabase sysname 
	set @SourceDatabase = quotename(parsename(@SourceTable, 3))
	



	--
	-- I de fall som tabellen är en temptabell sätts databasen till tempdb.
	-- (det för att kunna läsa systemvyer och ta reda på columner, mm)
	--
	if @SourceDatabase is null and left(parsename(@SourceTable, 1), 1) = '#' 
		set @SourceDatabase = quotename('tempdb')

	--
	-- Hjälpvariabler som lätt kan sprängas in i genererat sql-skript
	--
	declare @SQL_SourceDatabase varchar(512) 
	set @SQL_SourceDatabase = isnull(@SourceDatabase + '.', '')
	

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
	-- Kontrollera om tabell finns 
	--
	if object_id(@SourceTableFQN) is null
		begin
			raiserror ('Source table %s does not exists.', 16, 10, @SourceTable)
			return 1
		end



	select 
		@HtmlTable = '<table' + isnull(' class=''' + @TableCssClass + '''', '') + '><tr>'

	declare @ParamDef nvarchar(500)
	declare @MetaDataQuery nvarchar(max) = ''
	declare @DataSelectQuery nvarchar(max) = ''

	--
	-- Dynamisk SQL för att hämta information om kolumner i tabell.
	--
	select
		@MetaDataQuery = 
	'
	select
		@HtmlTable = @HtmlTable + ''<th>'' + 
			 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(c.name,''&'', ''&amp;''),''<'', ''&lt;''),''>'', ''&gt;''),''"'', ''&quot;''),'''''''', ''&#39;'')
			 + ''</th>''
		,@DataSelectQuery = @DataSelectQuery +
			''+''''<td>'''' + ''
			+ ''REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cast('' + quotename(c.name) + '' as nvarchar(max)),''''&'''', ''''&amp;''''),''''<'''', ''''&lt;''''),''''>'''', ''''&gt;''''),''''"'''', ''''&quot;''''),'''''''''''''''', ''''&#39;'''')''
			+ '' + ''''</td>''''''
	from
		' + @SQL_SourceDatabase + 'sys.columns c with (nolock)
	where
		c.object_id = object_id(''' + @SourceTableFQN + ''')
	order by
		c.column_id
	'

	--
	-- Anropa SQL och få ut bra info om hur html-tabellen ska se ut och fyllas med data.
	--
	set @ParamDef = '@HtmlTable nvarchar(max) output, @DataSelectQuery nvarchar(max) output'
	EXECUTE sp_executesql
		@MetaDataQuery
		,@ParamDef
		,@HtmlTable = @HtmlTable output
		,@DataSelectQuery = @DataSelectQuery output

	select
		@HtmlTable = @HtmlTable + '</tr>'

	--
	-- Bygg ihop dynamisk SQL som hämtar data från källtabell och konverterar det till html, <tr><td>...</td></tr>....
	--
	select
		@DataSelectQuery = 
	'select
		@HtmlTable = @HtmlTable + 
	(
	select' +
			'''<tr>'''
			+ @DataSelectQuery
			+ '+''</tr>'' + char(13) + char(10)' + '
	from
		' + @SourceTable + 
	case when len(@OrderBy) > 0 then + '
	order by
		' + @OrderBy 
	else
		''
	end + '
	for xml path(''''), type
	).value(''.'',''nvarchar(max)'') '

	

	set @ParamDef = '@HtmlTable nvarchar(max) OUTPUT'
	EXECUTE sp_executesql
		@DataSelectQuery
		,@ParamDef
		,@HtmlTable = @HtmlTable output


	set @HtmlTable = @HtmlTable + '</table>'
GO
