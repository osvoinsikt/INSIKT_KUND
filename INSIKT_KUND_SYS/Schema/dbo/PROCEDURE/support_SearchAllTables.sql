SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==================================================
--ExludeTables: Tabeller som inte matchar t.ex: ”%fact%” eller ”%writetable%” i databasen söks.
--SearchDataTypes: En kommaseparerad lista med datatyper som ska eftersökas.
--SearchDatabase: Vill man söka en annan databas än den som den anropas ifrån kan man även ange denna här. Sätter man den till ’LänkadServer.Databas’ och den länkade servern är en SQL Server så bör även det fungera.
-- ==================================================
CREATE PROCEDURE [dbo].[support_SearchAllTables]
(
	@SearchStr nvarchar(100)		
	,@ExcludeTables nvarchar(4000) = 'Document, FCDimension, FCDimensionMemberTranslation, FCProject, FCProjectPropertyValue, LangDictionary, UserSecurityGroup, SessionLog, ErrorLog, FCProperty,%fact_%,%writetable_%'
	,@SearchDataTypes nvarchar(4000) = 'char, varchar, nchar, nvarchar'
	,@SearchDatabase sysname = null
	,@TopCountFromEachTable int = 100
)
AS
BEGIN
	CREATE TABLE #Results (ColumnName nvarchar(370), ColumnValue nvarchar(3630))


	SET NOCOUNT ON

	if @SearchDatabase is null or len(@SearchDatabase) = 0
		select 
			 @SearchDatabase = DB_NAME(resource_database_id)
		From
			sys.dm_tran_locks 
		where 
			request_session_id = @@spid 
			and resource_type = 'DATABASE' 
			and request_owner_type = 'SHARED_TRANSACTION_WORKSPACE'
			and resource_database_id <> DB_ID()
	
	create table #ExcludeTablesTab 
	(
		ID int IDENTITY(1,1) NOT NULL PRIMARY KEY
		,TableSchema nvarchar(4000)
		,TableName nvarchar(4000)
	) 	
	create table #SearchDataTypesTab
	(
		ID int IDENTITY(1,1) NOT NULL PRIMARY KEY
		,DataType nvarchar(4000)
	) 

	declare @SplitString nvarchar(4000) 
	set @SplitString = @ExcludeTables
	declare @Delimiter nchar(1)
	set @Delimiter = ','

	declare @idx int        
    declare @slice nvarchar(4000)

	set @slice = null     
    set @idx = 1        
    if len(@SplitString)<=0 or @SplitString is null  return        
       
    while @idx!= 0        
    begin        
        set @idx = charindex(@Delimiter,@SplitString)        
        if @idx!=0        
            set @slice = left(@SplitString,@idx - 1)        
        else        
            set @slice = @SplitString        
                   
		insert into #ExcludeTablesTab(TableSchema,TableName) values(parsename(ltrim(rtrim(@slice)), 2), parsename(ltrim(rtrim(@slice)), 1))        
  
        set @SplitString = right(@SplitString,datalength(@SplitString)/2 - @idx)        
        if len(@SplitString) = 0 break        
    end    

	
	set @SplitString = @SearchDataTypes
	set @slice = null     
    set @idx = 1        
    if len(@SplitString)<=0 or @SplitString is null  return        
       
    while @idx!= 0        
    begin        
        set @idx = charindex(@Delimiter,@SplitString)        
        if @idx!=0        
            set @slice = left(@SplitString,@idx - 1)        
        else        
            set @slice = @SplitString        
                   
		insert into #SearchDataTypesTab(DataType) values(ltrim(rtrim(@slice)))        
  
        set @SplitString = right(@SplitString,datalength(@SplitString)/2 - @idx)        
        if len(@SplitString) = 0 break        
    end    

	declare @DynSQL nvarchar(max)	

	DECLARE @TableName nvarchar(256), @ColumnName nvarchar(128), @SearchStr2 nvarchar(110)
	SET  @TableName = ''
	SET @SearchStr2 = QUOTENAME('%' + @SearchStr + '%','''')


	set @DynSQL =
		'
			select 
				t.object_id
				,schema_name = s.name
				,table_name = t.name	
			from 
				' + ISNULL(@SearchDatabase + '.', '') +  'sys.tables t
					inner join ' + ISNULL(@SearchDatabase + '.', '') +  'sys.schemas s on
						s.schema_id = t.schema_id
			where
				t.is_ms_shipped = 0
				and t.type = ''U''
		'

	create table #Tables
	(
		object_id int not null primary key
		,schema_name sysname not null
		,table_name sysname not null
	)

	create table #SearchColumns
	(
		TableFCQ nvarchar(1000)
		,column_name nvarchar(1000)
		,column_expression nvarchar(1000)
	)

	insert into #Tables
	exec (@DynSQL)

	delete from t
	from
		#Tables t
			inner join #ExcludeTablesTab e on
				t.table_name like e.TableName
				and (t.schema_name like e.TableSchema or e.TableSchema is null)

	declare @object_id int
	select @object_id = MIN(OBJECT_ID) from #Tables
	while @object_id is not null
		begin
			set @DynSQL = 
			--;with SearchColumns as
			--(
				'
				select
					TableFCQ = QUOTENAME(tab.schema_name) + ''.'' + QUOTENAME(tab.table_name)
					,column_name = c.name
					,column_expression = 
						case 
							when t.name in (''xml'', ''ntext'') then
								''cast('' + QUOTENAME(c.name) + '' as nvarchar(max))''
							when t.name in (''text'') then
								''cast('' + QUOTENAME(c.name) + '' as varchar(max))''
							else
								QUOTENAME(c.name)
						end
				from
					#Tables tab
						inner join ' + ISNULL(@SearchDatabase + '.', '') +  'sys.columns c on
							c.object_id = tab.object_id
						inner join ' + ISNULL(@SearchDatabase + '.', '') +  'sys.types t on
							t.user_type_id = c.user_type_id
						inner join #SearchDataTypesTab st on
							st.DataType = t.name						
				where
					tab.object_id = ' + cast(@object_id as nvarchar(12)) + '
				'
			--)
			insert into #SearchColumns
			exec (@DynSQL)
			
			set @DynSQL = null
			

			select
				@DynSQL = ISNULL(@DynSQL + ' union ', '') +
					  'SELECT ' + isnull('top ' + cast(@TopCountFromEachTable as nvarchar(12)) +' ', '') + '''' + c.TableFCQ + '.' + QuoteName(c.column_name) + ''', LEFT(' + c.column_expression + ', 3630) '
					+ 'FROM ' + ISNULL(@SearchDatabase + '.', '') +  c.TableFCQ + ' (NOLOCK) ' 
					+ 'WHERE ' + c.column_expression + ' LIKE ' + @SearchStr2
			from
				#SearchColumns c
			order by
				c.column_name

			if @@ROWCOUNT > 0
				begin					
					raiserror('%s', 0, 0,@DynSQL) with nowait;

					INSERT INTO #Results
					exec (@DynSQL)
				end

			
			truncate table #SearchColumns
			select @object_id = MIN(OBJECT_ID) from #Tables where object_id > @object_id
		end

	SELECT ColumnName, ColumnValue FROM #Results order by ColumnName
	return
END
GO
