SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================================================
-- Author:		TRIMMA Affärsutveckling AB
-- Description:	Procedur för att underlätta skapande av historik på exempelvis en vy
--				innehållande snapshot-data.
--
--				Logiken för historikbyggandet är följande.
--              1. En en historiktabell för att hålla källvyns hisorik skapas.
--				2. En vy skapas som hämtar ut aktuella värden från historiktabellen
--				3. En trigger skapas på vyn med aktuellt värden som underhåller historiktabellen
--						För att uppdatera historiktabellens data körs INSERT/UPDATE/DELETE på
--						på vyn. Triggern skapar då loggposter med från och tilldatum i historik-
--						tabellen.
--						För att underlätta uppdatering av vyn rekomenderas proceduren app.SyncTable
--
--				Historiktabellen som skapas innhåller förutom källvyns samtliga kolumner även följande:
--					* HistID			ID för historikpost.
--					* Hist_FromDate		Datum/tid för när historikposten skapades.
--					* Hist_ToDate		Datum/tid när historikposten slutar att gälla. Alla 
--										aktuella historikposter gäller tills vidare och dessa 
--										får datumet 9999-12-31.
--					* Hist_PrevHistID	HistID på föregående historikpost för aktuell "primärnyckel"
--										eller 0 om det är första historikposten.
--					* Hist_IsCurrent	Flagga som säger om historikposten är aktuell, d.v.s. en 
--										rad som fanns i källvyn senast en synkronisering kördes.
-- ==================================================================================================
-- LOG:
--	2020-11-1, TRIMMA	Första försöket
-- ==================================================================================================
CREATE procedure [app].[HistView_Enable]
(
    @DataView nvarchar(512) -- Namn på käll-vy som historik ska byggas på.
    ,@PrimayKeyColumns nvarchar(max) = null-- Kommaseparerad lista med kolumner som är vyns "primära nyckel".

	,@HistDataTable nvarchar(512) = null -- Namn på tabell som kommer att skapas för att hålla historik.
	
	,@FirstFromBeginingOfTime bit = 0 -- Anger om först logposten ska gälla från dinosariernas tid eller från när laddjobbet först hittade posten.
	
    ,@Debug bit = 0
)
as
 
 
 
 
set nocount on

 
if @HistDataTable is null
    select @HistDataTable =
        isnull(quotename(parsename(replace(@DataView, '#', ''), 2)) + '.', '')
        + quotename(parsename(replace(@DataView, '#', ''), 1) + '_Hist')


declare @CurrentHistView  nvarchar(512)
select @CurrentHistView = 
	isnull(quotename(parsename(@HistDataTable, 2)) + '.', '') 
	+ quotename(parsename(@HistDataTable, 1) + '_Current')
 
declare @BuildHistTrigger nvarchar(512)
select @BuildHistTrigger = 
	isnull(quotename(parsename(replace(@DataView, '#', ''), 2)) + '.', '') 
	+ quotename('HistData_' + parsename(replace(@DataView, '#', ''), 1) + '_to_' + parsename(@HistDataTable, 1))
 

 declare @SourceObjectID int
 declare @SourceDatabase nvarchar(max) = ''

 if parsename(@DataView, 1) like '#%'
	begin
		set @SourceDatabase = 'tempdb.'
		set @SourceObjectID = object_id('tempdb..' + @DataView)
	end
else
	begin
		set @SourceDatabase = isnull(parsename(@DataView, 3) + '.', '')
		set @SourceObjectID = object_id(@DataView)
	end

if  @SourceObjectID is null
	raiserror('DataView %s not found.', 16, 10, @DataView)




declare
	@DynSQL nvarchar(max)
	,@DynSQLParam nvarchar(max) 

Create table #__SourceColumns
(
	ColumnName sysname
	,ColumnOrder int not null
	,SqlDataTypeExpression nvarchar(512)
	,CalcColDef nvarchar(max)
	,IsNullable bit
	,Collation sysname null
	,PrimaryKeyOrder tinyint
)
select
	@DynSQL = '
insert into #__SourceColumns
(
	ColumnName
	,ColumnOrder
	,SqlDataTypeExpression
	,CalcColDef
	,IsNullable
	,Collation
	,PrimaryKeyOrder
)
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
	,CalcColDef = calcCol.definition
	,IsNullable = col.is_nullable
	,Collation = col.collation_name
	,PrimaryKeyOrder = isnull(cast(pkOverride.ListPos as tinyint), pkCol.key_ordinal)
	
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
			and @PrimayKeyColumns is null
		left join ' + @SourceDatabase + 'sys.index_columns pkCol on
			pkCol.object_id = pkI.object_id
			and pkCol.index_id = pkI.index_id
			and pkCol.column_id = col.column_id
		left join ' + @SourceDatabase + 'sys.computed_columns calcCol on
            calcCol.object_id = col.object_id
            and calcCol.column_id = col.column_id
		left join app.Split(@PrimayKeyColumns, '','') pkOverride on
			parsename(pkOverride.Item, 1) = col.name
where
	col.object_id = @SourceObjectID
	and
    (
        object_id(@HistDataTable) is null
        or
        col.name in
        (
            select
                targetC.name
            from
                sys.columns targetC
            where
                targetC.object_id = object_id(@HistDataTable)
        )
    )
'

set @DynSQLParam = '@SourceObjectID int, @HistDataTable nvarchar(512), @PrimayKeyColumns nvarchar(max)'
exec sp_executesql 
	@DynSQL, @DynSQLParam
	,@SourceObjectID = @SourceObjectID
	,@HistDataTable = @HistDataTable
	,@PrimayKeyColumns = @PrimayKeyColumns


if not exists(select * from #__SourceColumns)
	raiserror('No columns found in source object (that exists in target hist table if that table exists).', 16, 10)

if not exists(select * from #__SourceColumns where PrimaryKeyOrder >= 1)
	raiserror('No primary key columns found in source object. Use parameter @PrimayKeyColumns to specify columns.', 16, 10)

declare @CreateTab nvarchar(max)
select @CreateTab =
'create table ' + @HistDataTable + '
(
    [HistID] int not null identity(1,1)
	,[Hist_FromDate] [datetime] NOT NULL
	,[Hist_ToDate] [datetime] NOT NULL
	,[Hist_PrevHistID] [int] NOT NULL
--	,[Hist_IsDeleted] [bit] NOT NULL
	,[Hist_IsCurrent] [bit] NOT NULL' + 
            (
                select
                    col_def = '
    ,' +
                        quotename(c.ColumnName) + ' ' +
                        case
                            when c.CalcColDef is not null then
                                'as ' + c.CalcColDef
                            else
                                c.SqlDataTypeExpression
								+
								case
									when c.Collation <> '' then ' collate ' + Collation
									else ''
								end
								+
								case c.IsNullable
									when 1 then ' null'
									else ' not null'
								end
                        end
                from
                    #__SourceColumns c
                order by
                    c.ColumnOrder
                for xml path, type).value(N'.[1]', N'nvarchar(max)')
                +
                '
	,
	CONSTRAINT [PK_' + parsename(@HistDataTable, 1) + '] PRIMARY KEY NONCLUSTERED 
	(
		[HistID] ASC
	)
)

CREATE CLUSTERED INDEX [IX_' + parsename(@HistDataTable, 1) + '_IsCurrent_HistID] ON ' + @HistDataTable + '
(
	[Hist_IsCurrent] ASC,
	[HistID] ASC
)

CREATE UNIQUE NONCLUSTERED INDEX [IX_' + parsename(@HistDataTable, 1) + '_CurLocicalPK] ON ' + @HistDataTable + '
(
	' + 
            (
                select
                  iif(row_number() over (order by c.PrimaryKeyOrder) > 1, ',', '') + quotename(c.ColumnName) + ' asc'
                from
                    #__SourceColumns c
				where
					PrimaryKeyOrder >= 1
                order by
                    c.PrimaryKeyOrder
                for xml path, type).value(N'.[1]', N'nvarchar(max)')
                +
                '
)
WHERE ([Hist_IsCurrent]=(1))

'
print '----------------------------------------------------------------------------------------------------'
print '-- Enable history logging for view ' + @DataView
print '----------------------------------------------------------------------------------------------------'
print '-- * Creating history data table: ' + @HistDataTable
if @CreateTab is null
    raiserror('	Unable to create table, no column defintions found. Verify that source view %s exists and that primary key columns are corretly supplied.', 16, 10, @DataView)

if object_id(@HistDataTable) is not null and @Debug = 0
	begin
		raiserror( '		WARNING:	History data table does already exist. The table is not altered by this procedure if needed.', 10,10)
		raiserror( '					Make sure it contains all columns. Use parameter @Debug = 1 to see expected DDL for the history table.', 10,10)
	end
else
	begin
		if (@Debug = 1)
			begin
			print 'GO'
			exec app.PrintMax @CreateTab
			print 'GO'
			end
		else
			exec (@CreateTab)
	end
 

--set @CurrentHistView
declare @CreateCurrentHistView nvarchar(max)
select @CreateCurrentHistView =
	iif( object_id(@CurrentHistView) is null, 'create', 'alter') + ' view ' + @CurrentHistView + ' as
select
	[HistID]
	,[Hist_FromDate]
	,[Hist_ToDate]
	,[Hist_PrevHistID]
	--,[Hist_IsDeleted]
	,[Hist_IsCurrent]' + 
            (
                select
                    '
    ,' + quotename(c.ColumnName)
                from
                    #__SourceColumns c
                order by
                    c.ColumnOrder
                for xml path, type).value(N'.[1]', N'nvarchar(max)')
                +
                '
from
	' + @HistDataTable + '
where
	[Hist_IsCurrent]=(1)
'

print '-- * Creating view for current data: ' + @CurrentHistView
if @CreateTab is null
    raiserror('	Unable to create view, no column defintions found. Verify that source view %s exists and that primary key columns are corretly supplied.', 16, 10, @DataView)
 
if (@Debug = 1)
	begin
		print 'GO'
		exec app.PrintMax @CreateCurrentHistView
		print 'GO'
	end
else
    exec (@CreateCurrentHistView)
	
declare @CreateBuildHistTrigger nvarchar(max)
select @CreateBuildHistTrigger = 
iif( object_id(@BuildHistTrigger) is null, 'create', 'alter') + ' TRIGGER ' + @BuildHistTrigger + '
ON ' + @CurrentHistView + '
INSTEAD OF INSERT, UPDATE, DELETE 
AS
set nocount on

declare @FromDate datetime = getutcdate()
update d set
	Hist_IsCurrent = 0
	,Hist_ToDate = @FromDate
from
	deleted del 
		inner join ' + @HistDataTable + ' d on
			d.HistID = del.HistID
--		left join inserted ins on
--			ins.HistID = del.HistID
--where
--	not (d.Hist_IsDeleted = 1 and ins.HistID is null) -- Försöker man ta bort en rad som redan är borttagen behöver vi inte göra något.

insert into ' + @HistDataTable + '
(
	[Hist_FromDate]
	,[Hist_ToDate]
	,Hist_PrevHistID
	,Hist_IsCurrent
	--,Hist_IsDeleted
	' + 
            (
                select
                    '
    ,' + quotename(c.ColumnName)
                from
                    #__SourceColumns c
				where
					c.CalcColDef is null
                order by
                    c.ColumnOrder
                for xml path, type).value(N'.[1]', N'nvarchar(max)')
                +
                '
)
/*
--
-- Borttaget data
--
select
	[Hist_FromDate] = @FromDate
	,[Hist_ToDate] = ''9999-12-31''
	,Hist_PrevHistID = HistID
	,Hist_IsCurrent = 1
	,Hist_IsDeleted = 1
	' + 
            (
                select
                    '
    ,' + quotename(c.ColumnName)
                from
                    #__SourceColumns c
				where
					c.CalcColDef is null
                order by
                    c.ColumnOrder
                for xml path, type).value(N'.[1]', N'nvarchar(max)')
                +
                '
from
	deleted 
where 
	HistID not in
	(
		select HistID from inserted
	)
	and Hist_IsDeleted = 0 
union all
*/
--
-- Nytt/ändrat data
--
select
	[Hist_FromDate] = ' + iif(@FirstFromBeginingOfTime = 1 , 'iif(HistID = 0, ''1900-01-01'', @FromDate)', '@FromDate') + '
	,[Hist_ToDate] = ''9999-12-31''
	,Hist_PrevHistID = HistID
	,Hist_IsCurrent = 1
	--,Hist_IsDeleted = 0
	' + 
            (
                select
                    '
    ,' + quotename(c.ColumnName)
                from
                    #__SourceColumns c
				where
					c.CalcColDef is null
                order by
                    c.ColumnOrder
                for xml path, type).value(N'.[1]', N'nvarchar(max)')
                +
                '
from
	inserted
'


print '-- * Creating trigger for building history: ' + @BuildHistTrigger + ' on view'
print '     ' + @CurrentHistView
if @CreateTab is null
    raiserror('	Unable to create trigger, no column defintions found. Verify that source view %s exists and that primary key columns are corretly supplied.', 16, 10, @DataView)
 
if (@Debug = 1)
	begin
		print 'GO'
		exec app.PrintMax @CreateBuildHistTrigger
		print 'GO'
	end
else
    exec (@CreateBuildHistTrigger)



declare @SnippetHelp nvarchar(max)


select @SnippetHelp = 
 'exec app.SyncTable
	@SourceTable = ''' + @DataView+ '''
	,@TargetTable = ''' + @CurrentHistView + '''
	,@JoinColumns = ''' + 
            (
                select
                  iif(row_number() over (order by c.PrimaryKeyOrder) > 1, ',', '') + quotename(c.ColumnName)
                from
                    #__SourceColumns c
				where
					c.PrimaryKeyOrder >= 1
                order by
                    c.PrimaryKeyOrder
                for xml path, type).value(N'.[1]', N'nvarchar(max)')
                +
                ''''
print ''
print '----------------------------------------------------------------------------------------------------'
print '-- För att på ett effektivt synka vyn ' + @DataView + ' till historiktabellen'
print '-- ' + @HistDataTable + ' kan nedan kodsnutt användas:'
print '----------------------------------------------------------------------------------------------------'
print @SnippetHelp

drop table #__SourceColumns
GO
