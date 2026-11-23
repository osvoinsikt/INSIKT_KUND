SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[FactSumView_Create]
(
    @SourceFactTable nvarchar(512)
    ,@DimColumns nvarchar(max) = null
    ,@MeasureColumns nvarchar(max) = null
	,@CreateWithoutIndex bit = 0
	,@TargetFactIxView nvarchar(512) = null
	,@TargetFactSumView nvarchar(512) = null
    ,@Debug bit = 0
)
as
 
  
--
-- Standardvariabler
--
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount
 
 
begin try


set @CreateWithoutIndex = isnull(@CreateWithoutIndex, 0)
  
set nocount on
declare @ObjectName nvarchar(512)


if @TargetFactSumView is null
	begin
		set @ObjectName = parsename(@SourceFactTable, 1) + '_Sum';
		if len(@ObjectName) > 128 raiserror('Target SumView name is too long (%s). Max 128 characters allowed.', 16, 10, @ObjectName)
		set @TargetFactSumView =
			isnull(quotename(parsename(@SourceFactTable, 2)) + '.', '')
			+ quotename(@ObjectName)
	end

if @TargetFactIxView is null
	begin
		set @ObjectName = replace(parsename(@TargetFactSumView, 1), '_Sum', '') + '_IxSum';
		if len(@ObjectName) > 128 raiserror('Target IxView name is too long (%s). Max 128 characters allowed.', 16, 10, @ObjectName)

		set @TargetFactIxView =
			isnull(quotename(parsename(@SourceFactTable, 2)) + '.', '')
			+ quotename(@ObjectName);
	end 
 

       

declare @TriggerName nvarchar(max)
select @TriggerName = 'TR_' + parsename(@SourceFactTable, 1) + '_to_' + parsename(@TargetFactIxView, 1)
 
 if len(@TriggerName) > 128 set @TriggerName = left(@TriggerName, 120) + convert(nvarchar(8), cast(checksum(@TriggerName) as binary(4)), 2)

declare @IndexName nvarchar(max)
select @IndexName = 'IX_GrpSum_' + parsename(@TargetFactIxView, 1)

 if len(@IndexName) > 128 set @IndexName = left(@IndexName, 120) + convert(nvarchar(8), cast(checksum(@IndexName) as binary(4)), 2)

declare @NewLine nvarchar(max) = nchar(13) + nchar(10)


--
-- För att undvika problem med krock med gamla FactWithSpecial, kontrollera att det inte blir krock.
--
declare @OldSumSumUpdateViewName nvarchar(512), @OldSumSumUpdateViewSchemaName nvarchar(512)

select
	@OldSumSumUpdateViewName = v.name
	,@OldSumSumUpdateViewSchemaName = s.name
from
	sys.tables t
		inner join sys.views v on
			v.name = t.name + '_Sum_Update'
			and v.schema_id = t.schema_id
		inner join sys.schemas s on
			s.schema_id = t.schema_id
where
	t.object_id = OBJECT_ID(@SourceFactTable)
	and v.name != parsename(@TargetFactSumView, 1)
	and OBJECT_DEFINITION(v.object_id) like '%Support_CreateFactView_WithSpecial%'
	
if @OldSumSumUpdateViewName is not null
	begin
		declare @UpgradeMessageScript nvarchar(max)
		select @UpgradeMessageScript = 
			N'--' + @NewLine +
			N'-- Ta bort den gamla _Sum_Update-vyn' + @NewLine +
			N'--' + @NewLine +
			N'drop view ' + QUOTENAME(@OldSumSumUpdateViewSchemaName) + '.' + quotename(@OldSumSumUpdateViewName) + @NewLine + 
			N'' + @NewLine +
			N'--'  + @NewLine +
			N'-- Skapa nya Sum-vyer enligt senaste snitt.'  + @NewLine +
			N'--' + @NewLine +
			N'exec ' + @ProcName + @NewLine +
			N'	@SourceFactTable = ''' + @SourceFactTable + '''' + @NewLine +
			N'	,@DimColumns = ' + isnull('''' + @DimColumns + '''', 'NULL') + @NewLine +
			N'	,@MeasureColumns = ' + isnull('''' + @MeasureColumns + '''', 'NULL') + @NewLine +
			N'	,@TargetFactIxView = ''' + @TargetFactIxView + '''' + @NewLine +			
			N'	,@TargetFactSumView = ''' + @TargetFactSumView + '''' + @NewLine +			
			N'' + @NewLine +
			N'--' + @NewLine +
			N'-- Objekt som måste ändras från att använda: ' + QUOTENAME(@OldSumSumUpdateViewSchemaName) + '.' + quotename(@OldSumSumUpdateViewName) + '' + @NewLine +
			N'-- till att istället använda: ' + @TargetFactSumView + '' + @NewLine +
			N'--' + @NewLine +
			N'select type_desc, name from sys.objects where object_definition(object_id) like ''%' + @OldSumSumUpdateViewName + '%'''

		raiserror('Rester av gamla FactWith special finns kopplat till denna faktatabell.
Droppa _Sum_Update-vyn, kör detta igen och uppdatera därefter alla laddprocedurer som använder _Sum_Update-vyn till att istället använda _Sum-vyn.

Nedan hjälpscript underlättar uppgradering:

%s', 16, 10, @UpgradeMessageScript)

	end


  
select distinct
    ColumnName = isnull(ParseName(c.Item, 1), c.Item)
into #MeasureColumn
from
    app.SplitObjectList(@MeasureColumns) c

select distinct
    ColumnName = isnull(ParseName(c.Item, 1), c.Item)
	,ColumnOrder = c.ListPos
into #DimColumn
from
    app.SplitObjectList(@DimColumns) c
 select
    tab.object_id
    ,c.column_id
    ,c.name
    ,c.is_identity
    --,forceMeasure_ColumnName = forceMeasure.ColumnName
    ,is_measure =
        case
            when
                (
                    forceMeasure.ColumnName <> ''                
                )
            then 1
            when
                isnull(@MeasureColumns, '') = ''
                and
                c.name not in
                ( 
                    select parsename(IDColumnName, 1)From app.DimensionPartType
                )
                and
                c.system_type_id in
                (
                    59 -- real
                    ,60 -- money
                    ,62 -- float
                    ,106 -- decimal
                    ,108 -- numeric
                    ,122 -- smallmoney
                )
                and forceDim.ColumnName is null
            then 1
            else 0
            end
--  ,forceDim_ColumnName = forceDim.ColumnName
    ,is_dimension =
        case
            when
                (
                    forceDim.ColumnName <> ''                
                )
            then 1
            when
                isnull(@DimColumns, '') = ''
                and
                c.name not in('ID', 'RowTypeID')
                and c.Name like '%ID'
                and ISNULL(TYPE_NAME(c.system_type_id), t.name) like '%int'
                and forceMeasure.ColumnName is null
                 then 1
            else 0
        end
    ,is_exists_in_writetable =
        case
            when c.name like 'Exist%Write%' and ISNULL(TYPE_NAME(c.system_type_id), t.name) in ('int', 'smallint', 'bit') then 1
            else 0
        end
    ,is_incupdate =
        case
            when c.name like 'IncUpdate' and ISNULL(TYPE_NAME(c.system_type_id), t.name) in ('int', 'smallint', 'bit') then 1
            else 0
        end
    ,is_audituser =
        case
            when c.name like '%Audit%User' and ISNULL(TYPE_NAME(c.system_type_id), t.name) like '%char%' then 1
            else 0
        end
    ,is_audittime =
        case
            when (c.name like '%Audit%Time' or c.name like '%Audit%Date') and ISNULL(TYPE_NAME(c.system_type_id), t.name) like '%atetime%' then 1
            else 0
        end
    ,is_rowtype =
        case
            when c.name in ('RowType', 'RowTypeID') and ISNULL(TYPE_NAME(c.system_type_id), t.name) in ('int', 'smallint') then 1
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
        convert(tinyint,CASE                -- int/decimal/numeric/real/float/money
                WHEN c.system_type_id IN (48, 52, 56, 59, 60, 62, 106, 108, 122, 127) THEN c.precision END)
    ,numeric_precision_radix = convert(smallint, CASE   -- int/money/decimal/numeric
        WHEN c.system_type_id IN (48, 52, 56, 60, 106, 108, 122, 127) THEN 10
        WHEN c.system_type_id IN (59, 62) THEN 2 END)   -- real/float
    ,numeric_scale = convert(int, CASE  -- datetime/smalldatetime
        WHEN c.system_type_id IN (40, 41, 42, 43, 58, 61) THEN NULL
        ELSE ODBCSCALE(c.system_type_id, c.scale) END)
    ,datetime_precision = convert(smallint, CASE -- datetime/smalldatetime
        WHEN c.system_type_id IN (40, 41, 42, 43, 58, 61) THEN ODBCSCALE(c.system_type_id, c.scale) END)
--  ,collation_name = c.collation_name
 
    ,default_def = dc.definition
	,ForceIndexOrder = forceDim.ColumnOrder
    ,SumViewDefaultKey = 'DEF:' + quotename(sh.name) + '.' + quotename(parsename(@TargetFactSumView, 1)) + '.' + quotename(c.name)
      
into #SourceColumns
from
    sys.tables tab
        inner join sys.schemas sh on
            sh.schema_id = tab.schema_id
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
        left join sys.default_constraints dc on
            dc.parent_object_id = tab.object_id
            and dc.parent_column_id = c.column_id
        left join #DimColumn forceDim on
            forceDim.ColumnName = c.name
        left join #MeasureColumn forceMeasure on
            forceMeasure.ColumnName = c.name
  
where
    tab.object_id = object_id(@SourceFactTable)


 declare @Header nvarchar(max)
 select @Header =
'-------------------------------------------------------------------------------------
-- OBS!
-------------------------------------------------------------------------------------
-- Denna vy är automatiskt genererad av ' + app.GetObjectFullName(@@procid) +  '
-- Ev. ändringar kan skrivas över.
-------------------------------------------------------------------------------------
--
-- Detta är en del av ett ramverk för att underlätta och snabba upp group by/sum av
-- en transaktionsfaktatabell samt att ge möjlighet att generera ändringstransaktioner
-- genom att möjlig göra insert/update på den grupperade vyn.
--
--
-- Ingående objekt för transaktionstabellen: ' + @SourceFactTable + '
-- * Indexerad vy: ' + @TargetFactIxView  + '
--       - Index: ' + @IndexName + '
-- * Select/Update-vy med trigger: ' + @TargetFactSumView  + '
--       - Trigger: ' + @TriggerName + '
--
--
-- På grund av att vyn ' + @TargetFactIxView + ' är skapad med
-- schemabinding för att möjliggöra skapande av index på den blir det svårt att
-- ändra underliggande tabellstruktur.
--
-- För att tillfälligt ta bort schemabinding och index, använd:
-- exec app.FactSumView_Disable ''' + @SourceFactTable +  '''
-- exec app.FactSumView_Enable ''' + @SourceFactTable +  '''
--
-------------------------------------------------------------------------------------
'
++ 
iif(@CreateWithoutIndex = 0, '',
'--
-- OBS! OBS! OBS!
--
-- ' + @TargetFactIxView + ' är just nu skapad utan Index och SCHEMABINDING för att 
-- underlätta uppdatering av underliggande tabell.
--
-------------------------------------------------------------------------------------
')
+ 
'--
-- Kör nedanstående för att återskapa vyn:
--
/*
exec ' + @ProcName +  '
    @SourceFactTable = ''' + @SourceFactTable + '''
    ,@DimColumns = ' + isnull('''' + @DimColumns + '''', 'NULL') + '
    ,@MeasureColumns = ' + isnull('''' + @MeasureColumns + '''', 'NULL') + '
    ,@TargetFactIxView = ''' + @TargetFactIxView + '''
	,@TargetFactSumView = ''' + @TargetFactSumView + '''
*/

-------------------------------------------------------------------------------------
-- Via triggers i Sum-vyn kan diffposter genereras i underliggande faktatabell
-- Alltså via INSERT/UPDATE/DELETE i ' +  @TargetFactSumView + '
--
-- Proceduren app.SyncTable fungerar väldigt bra för att underlätta dessa operation:
-- Ex:
/*
'
+
isnull
(
    (
        select top 1
'--
-- Sätt defaultvärden på icke-dimensions/measures-kolumner. Dessa sessionsvariabler påverkar sum-vyns-trigger.
-- Om motsvarande kolumn även finns i @SourceTable så används det värdet i första hand (obs! går ej att sätta vid delete).
--

-- Defaultvärde på ' + c.name + '
exec sys.sp_set_session_context 
	@key = N''' + c.SumViewDefaultKey + ''',
	@value = ' + iif(c.data_type like '%char%' or c.data_type like '%date%', '''abc''', '1234') + ';

'
            from
                #SourceColumns c
            where
                c.is_measure = 0
                and c.is_dimension = 0
                and c.is_computed = 0
                and c.is_identity = 0                
            order by
                iif(c.name like '%RowType%', 0, 1)
                ,c.is_audittime
                ,c.is_audituser
                
        )
        ,N''
) + '-- Skapa diffposter i underliggande faktatabell via SyncTable och Sum-vy
exec app.SyncTable
    @TargetTable = ''' + @TargetFactSumView + '''
    ,@SourceTable= ''#' + parsename(@SourceFactTable, 1) + '''
    ,@JoinColumns = ''' 
    + 
    (
        select
            iif(row_number() over (order by c.column_id) > 1, ', ', '') + quotename(c.name)
        from
            #SourceColumns c
        where
            c.is_dimension = 1
                     
        order by
            c.column_id
        for xml path, type
    ).value(N'.[1]', N'nvarchar(max)')
    + '''

*/
-------------------------------------------------------------------------------------
'

 

declare @MissingForceDim nvarchar(max)

select
	@MissingForceDim =
		stuff
		(
			(
				select
					N', ' + quotename(forceDim.ColumnName)
				from
					#DimColumn forceDim
						left join #SourceColumns dim on
							dim.name = forceDim.ColumnName
							and dim.is_dimension = 1
				where
					dim.object_id is null
				for xml path(''),type
			).value('(./text())[1]','nvarchar(MAX)')
			,1,2,''
		)

if @MissingForceDim <> ''
	begin
		raiserror('Unable to set all requested dimension columns. Missing: %s', 16, 10, @MissingForceDim);
		return;
	end


declare @MissingForceMeasure nvarchar(max)

select
	@MissingForceMeasure =
		stuff
		(
			(
				select
					N', ' + quotename(forceDim.ColumnName)
				from
					#MeasureColumn forceDim
						left join #SourceColumns dim on
							dim.name = forceDim.ColumnName
							and dim.is_measure = 1
				where
					dim.object_id is null
				for xml path(''),type
			).value('(./text())[1]','nvarchar(MAX)')
			,1,2,''
		)

if @MissingForceMeasure <> ''
	begin
		raiserror('Unable to set all requested measure columns. Missing: %s', 16, 10, @MissingForceMeasure);
		return;
	end  

declare @CreatTargetFactView nvarchar(max)
declare @DropTargetFactView nvarchar(max)

if object_id(@TargetFactIxView) is not null
    begin
         
        select @DropTargetFactView = 'drop view ' + @TargetFactIxView
    end
 
 
select @CreatTargetFactView =
@Header + 'create view ' + @TargetFactIxView + iif(@CreateWithoutIndex = 1, '', ' with schemabinding') + ' as
SELECT' +
(
    select
        col_def = '
    '
            + iif(row_number() over (order by c.column_id) > 1, ',', '')
			+
			case 
				when c.is_incupdate = 1 then
					quotename('NrOfIncUpdateRows')
				else
					quotename(c.name)
			end
			+ ' = ' +
            case
                when c.is_measure = 1 then                             
                    'sum('
                    +
                    iif
                    (   c.is_nullable = 1
                        ,'isnull(f.' + quotename(c.name) + ', 0)'
                        ,'f.' + quotename(c.name)
                    )
                    +
                    ')'
				when c.is_incupdate = 1 then
					'sum('
                    +
					iif(c.data_type in ('bit', 'smallint'), 'cast(', '')
					+
                    iif
                    (   c.is_nullable = 1
                        ,'isnull(f.' + quotename(c.name) + ', 0)'
                        ,'f.' + quotename(c.name)
                    )
					+
					iif(c.data_type in ('bit', 'smallint'), ' as int)', '') 
                    +
                    ')'
                else
                    'f.' + quotename(c.name)
            end
    from
        #SourceColumns c
    where
        c.is_measure = 1
        or c.is_dimension = 1
		or c.is_incupdate = 1
                     
    order by
        c.column_id
    for xml path, type).value(N'.[1]', N'nvarchar(max)')
    +
    '
    ,[RowCnt] = count_big(*)
from
    ' + @SourceFactTable + ' f
group by' +
    (
        select
            col_def = '
    '
                + iif(row_number() over (order by c.column_id) > 1, ',', '') +
                'f.' + quotename(c.name)
        from
            #SourceColumns c
        where
            c.is_dimension = 1
                     
        order by
            c.column_id
        for xml path, type
    ).value(N'.[1]', N'nvarchar(max)')
 
 
declare @CreateIndex nvarchar(max) 
select @CreateIndex =
'create unique clustered index ' + quotename(@IndexName) + ' on ' + @TargetFactIxView + '
(' +
    (
        select
            col_def = '
    '       + iif(row_number() over (order by c.ForceIndexOrder, c.column_id) > 1, ',', '') +
                quotename(c.name)
        from
            #SourceColumns c
        where
            c.is_dimension = 1
                     
        order by
			c.ForceIndexOrder
            ,c.column_id
        for xml path, type
    ).value(N'.[1]', N'nvarchar(max)') + '
)'
 
 
 
declare @DropTargetFactUpdateView nvarchar(max)
declare @CreateTargetFactUpdateView nvarchar(max)
        if object_id(@TargetFactSumView) is not null
            begin
                select @DropTargetFactUpdateView = 'drop view ' + @TargetFactSumView
            end
 
        select @CreateTargetFactUpdateView = @Header + 'create view ' + @TargetFactSumView + ' as
SELECT' +
            (
                select
                    col_def = '
    '
                        + iif(row_number() over (order by c.column_id, incUpdateCol.is_nr_of_incupdate_rows desc) > 1, ',', '') +
                        quotename(coalesce(incUpdateCol.name, c.name)) 
						+ ' = ' +
                        case
                            when c.is_measure = 1 or c.is_dimension = 1 or incUpdateCol.is_nr_of_incupdate_rows = 1 then
                                'f.' + quotename(coalesce(incUpdateCol.name, c.name))
                            else
                                'cast(null as ' +
                                    c.data_type +
                                    case c.data_type
                                        when 'sql_variant' then ''
                                        when 'text' then ''
                                        when 'ntext' then ''
                                        when 'xml' then ''
                                        when 'decimal' then '(' + cast(numeric_precision as varchar) + ', ' + cast(numeric_scale as varchar) + ')'
                                        else coalesce('('+case when character_maximum_length = -1 then 'MAX' else cast(character_maximum_length as varchar) end +')','')
                                    end
                                + ')'
                        end
                from
                    #SourceColumns c
						-- Duplicera IncUpdate-tabell till två kolumner, en som blir NrOfIncUpdateRows och en "vanlig"
						left join (select is_nr_of_incupdate_rows = 1, name = N'NrOfIncUpdateRows' union all select 0, null) incUpdateCol on
							c.is_incupdate = 1
                where
                    c.is_identity = 0
                    and c.is_computed = 0
                     
                order by
                    c.column_id
					,incUpdateCol.is_nr_of_incupdate_rows desc
                for xml path, type).value(N'.[1]', N'nvarchar(max)')
                + '
from
    ' + @TargetFactIxView + ' f' + iif(@CreateWithoutIndex = 0,' with (noexpand)', '')
 
 
 
 declare @CreateTrigger nvarchar(max)
 select @CreateTrigger = @Header +
 'create  trigger ' + quotename(@TriggerName) + ' on ' + @TargetFactSumView + '
INSTEAD OF INSERT, UPDATE, DELETE
as
begin
set nocount on
insert into ' + @SourceFactTable + '
(' +
    (
                select
                    col_def = '
    '
                        + iif(row_number() over (order by c.column_id) > 1, ',', '') +
                        quotename(c.name)
                from
                    #SourceColumns c
                where
                    c.is_identity = 0
                    and c.is_computed = 0
                     
                order by
                    c.column_id
                for xml path, type).value(N'.[1]', N'nvarchar(max)')
                + '
)
select' +
    (
                select
                    col_def = '
    '
                        + 
                        isnull(
                        iif(row_number() over (order by c.column_id) > 1, ',', '') +
                        quotename(c.name) + ' = '
                        +
                        case
                            when c.is_dimension = 1 then
                                'isnull(i.' +  quotename(c.name) + ', d.' +  quotename(c.name) + ')'
                            when c.is_measure = 1 then
                                'nullif(isnull(i.' + quotename(c.name) + ', 0) - isnull(d.' + quotename(c.name) + ', 0), 0)'
                            else
                                'coalesce(i.' +  quotename(c.name)                                 
                                
                                -- Get Default from session
                                + ',cast(session_context(N''' + c.SumViewDefaultKey + ''') as ' +
                                    c.data_type +
                                    case c.data_type
                                        when 'sql_variant' then ''
                                        when 'text' then ''
                                        when 'ntext' then ''
                                        when 'xml' then ''
                                        when 'decimal' then '(' + cast(numeric_precision as varchar) + ', ' + cast(numeric_scale as varchar) + ')'
                                        else coalesce('('+case when character_maximum_length = -1 then 'MAX' else cast(character_maximum_length as varchar) end +')','')
                                    end
                                + ')'

                                -- Get Default from target columns Default Constraint
                                + iif(c.default_def <> '', ',' + c.default_def, '')

                                -- Get Default from current user
                                + iif(c.is_audituser = 1, ', suser_name()', '')

                                -- Get Default from current utc time
                                + iif(c.is_audittime = 1, ', getutcdate()', '')
                                + ')'
                        end
                        ,'<NULL error in column definition>')                                 
                from
                    #SourceColumns c
                where
                    c.is_identity = 0
                    and c.is_computed = 0
                     
                order by
                    c.column_id
                for xml path, type).value(N'.[1]', N'nvarchar(max)')
                + '
from
    inserted i
        full join deleted d on' +
    (
                select
                    col_def = '
            '
                        + iif(row_number() over (order by c.column_id) > 1, 'and ', '') +
                        'd.' + quotename(c.name) + ' = i.' + quotename(c.name)
                                 
                from
                    #SourceColumns c
                where
                    c.is_dimension = 1
                     
                order by
                    c.column_id
                for xml path, type).value(N'.[1]', N'nvarchar(max)')
                + '
where' +
    (
                select
                    col_def = '
    '
                        + iif(row_number() over (order by c.column_id) > 1, 'or ', '') +
                        'abs( nullif(isnull(i.' + quotename(c.name) + ', 0) - isnull(d.' + quotename(c.name) + ', 0), 0) ) > 0.00001'
                                 
                from
                    #SourceColumns c
                where
                    c.is_measure = 1
                     
                order by
                    c.column_id
                for xml path, type).value(N'.[1]', N'nvarchar(max)')
                + '
end
'
     
--print @CreatTargetFactView
         
        if @CreatTargetFactView is null
            raiserror('Unable to create table, no column defintions found. Verify that source fact-table %s exists.', 16, 10, @SourceFactTable)
  
        if (@Debug = 1)
            begin
                if @DropTargetFactUpdateView is not null
                    begin
                        print @DropTargetFactUpdateView
                        print 'go'
                    end
                if @DropTargetFactView is not null
                    begin
                        print @DropTargetFactView
                        print 'go'
                    end
                 
                exec app.PrintMax @CreatTargetFactView
                print 'go'
				if @CreateWithoutIndex =0
					begin
						exec app.PrintMax @CreateIndex
						print 'go'
					end
                exec app.PrintMax @CreateTargetFactUpdateView
                print 'go'
                exec app.PrintMax @CreateTrigger
                print 'go'
                 
            end
        else
            begin
                if @TranCount = 0 begin tran
                if @DropTargetFactUpdateView is not null
                    begin
                        print 'Drop update view: ' + @TargetFactSumView
                        exec (@DropTargetFactUpdateView)
                    end
                if @DropTargetFactView is not null
                    begin
                        print 'Drop indexed view: ' + @TargetFactIxView
                        exec (@DropTargetFactView)
                    end
					
                print 'Create view: ' + @TargetFactIxView
                exec (@CreatTargetFactView)
				if @CreateWithoutIndex =0
					begin
						print 'Create indexed: ' + @IndexName
						exec (@CreateIndex)
					end
                print 'Create update view: ' + @TargetFactSumView
                exec (@CreateTargetFactUpdateView)
                 
                print 'Create update trigger: ' + @TriggerName
                exec (@CreateTrigger)
                if @TranCount = 0 commit tran
            end
  
 
 
 
end try
begin catch	
    --
    -- Rulla tillbaka eventualla transaktioner startade i den här procedurn och logga fel.
    --
    if @TranCount = 0 and @@trancount > 0 rollback tran;
		
    throw;
end catch
GO
