SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[Support_Generate_FCObjectEvent]
(
    @INSIKT_SYS nvarchar(max) -- SYS-databas där FCObject finns
    ,@FCObjectTypeID int -- FCObjectTypeID
    ,@SyncToDimensionPartTypeID nvarchar(512) = null -- I de fall vi vill synca ett FCObject till en base-tabell kan denna parameter användas för att göra livet enklare.
    ,@EventFilter nvarchar(max)  = null -- Like-villkor som filtrerar vilka event som ska genereras, NULL = samtliga FCObjectEvent event.
)
as
begin try
  
  
declare @SyncToDimensionPartSnippet nvarchar(max)
if @SyncToDimensionPartTypeID is not null
    begin
        declare
            @DimensionPartType_Target nvarchar(512)
            ,@DimensionPartType_Source nvarchar(512)
            ,@DimensionPartType_IdColumn nvarchar(512)
  
        select
            @DimensionPartType_Target = dp.TableName
            ,@DimensionPartType_Source = isnull(quotename(parsename(dp.TableName, 2)) + N'.', N'') + quotename(parsename(dp.TableName, 1) + N'_FCObjectSource')
            ,@DimensionPartType_IdColumn = dp.IDColumnName
        from
            app.DimensionPartType dp
        where
            dp.DimensionPartTypeID = @SyncToDimensionPartTypeID
  
        if @@ROWCOUNT = 0
            raiserror('DimensionPartTypeID = %i not found in app.DimensionPartType.', 16, 10, @SyncToDimensionPartTypeID)
  
        if object_id(@DimensionPartType_Target, 'U') is null
            raiserror('DimensionPartType table %s does not exists or is not a user table.', 16, 10, @DimensionPartType_Target)
  
        if object_id(@DimensionPartType_Source) is null
            raiserror
            (
                'DimensionPartType source view %s does not exists. Create this view with the same columns as %s but read from FCObject. FCObjectID must equal %s . ', 16, 10
                ,@DimensionPartType_Source
                ,@DimensionPartType_Target
                ,@DimensionPartType_IdColumn
            )
          
  
          
        declare
            @DeleteMode int = 1 -- Ta bort rader som inte finns
            ,@DeleteColumn nvarchar(512) =  '_DoNotUseNormalIsDeletedBehaviourToForceSyncWithSourceIsDeletedColumn_'
  
        --
        -- Saknas IsDeleted-kolumn i SourceView
        --
        if not exists(select * from  sys.columns where OBJECT_ID = OBJECT_ID(@DimensionPartType_Source) and name = 'IsDeleted')
            begin
                set @DeleteMode = 2 -- Uppdatera IsDeleted-flagga om en rad tas bort.
                set @DeleteColumn = 'IsDeleted'
            end
  
        select
            @SyncToDimensionPartSnippet =
            N'
              
            --
            -- Sync Changed FCObject row to dimension part type base-table.
            --
            select
                *
            into
                #FCObject_SourceData
            from
                ' + @DimensionPartType_Source + '
            where
                ' + @DimensionPartType_IdColumn + ' = @FCObjectID
  
            declare @TargetFilter nvarchar(max)
            select @TargetFilter = N''''' + @DimensionPartType_IdColumn + ' = '''' + cast(@FCObjectID as nvarchar(max))
              
            exec app.SyncTable
                @SourceTable = ''''#FCObject_SourceData''''
                ,@TargetTable = ''''' + @DimensionPartType_Target + '''''
                ,@DeleteMode = ' + CAST(@DeleteMode as nvarchar(max)) + '
                ,@DeleteColumn = ''''' + @DeleteColumn + '''''
                ,@TargetFilter = @TargetFilter
                ,@SynchronizedBy = @EventName
            '
    end
  
  
if LEN(@EventFilter) = 0 or @EventFilter is null
    set @EventFilter = N'%'
  
declare
    @EventValidationUpdate nvarchar(max)
    ,@EventHandlerProc nvarchar(max)
  
  
  
declare @DynSQL nvarchar(max)
select
     @DynSQL = N'
;With FCPropertyrData as
(
    select
        ID, FCObjectTypeID, FCObjectPropertyControlID, FCObjectPropertyDatatypeID, Name
        ,ParameterName = cast(p.Name as nvarchar(max))
        ,InValidCharAt = cast(PATINDEX(''%[^a-z0-9 åäö]%'', p.Name) as int)
    from
        ' + @INSIKT_SYS + N'.dbo.FCObjectProperty p
    where
        p.isVisible = 1
    union all
    select
        prev.ID, prev.FCObjectTypeID, prev.FCObjectPropertyControlID, prev.FCObjectPropertyDatatypeID, prev.Name
        ,ParameterName = cast(left(prev.ParameterName, prev.InValidCharAt - 1) + SUBSTRING(prev.ParameterName,  prev.InValidCharAt + 1, 1000) as nvarchar(max))
        ,InValidCharAt = cast(PATINDEX(''%[^a-z0-9_åäö]%'', left(prev.ParameterName, prev.InValidCharAt - 1) + SUBSTRING(prev.ParameterName,  prev.InValidCharAt + 1, 1000)) as int)
    from
        FCPropertyrData prev
    where
        prev.InValidCharAt > 0
)
,
FCPropertyParameter as
(
    select
        p.ID, p.FCObjectTypeID, p.FCObjectPropertyControlID, p.FCObjectPropertyDatatypeID, p.Name
        ,ParameterName = N''@'' + REPLACE(ParameterName, '' '', ''_'')
        ,DataType = dt.Name
        ,SqlDataType =
            case dt.Name
                when ''string'' then ''nvarchar(3000)''
                when ''bit'' then ''bit''
                when ''int'' then ''int''
                when ''float'' then ''float''
                when ''datetime'' then ''datetime''
            end
        ,ToEventMessageStr =
            case dt.Name
                when ''string'' then N'''''''''''''''''' + cast(@'' + REPLACE(ParameterName, '' '', ''_'') + N'' as nvarchar(max)) + ''''''''''''''''''
                when ''datetime'' then N'''''''''''''''''' + convert(nvarchar(max), @'' + REPLACE(ParameterName, '' '', ''_'') + N'', 121) + ''''''''''''''''''
                else N''cast(@'' + REPLACE(ParameterName, '' '', ''_'') + N'' as nvarchar(max))''
            end
    from
        FCPropertyrData p
            inner join ' + @INSIKT_SYS + N'.dbo.FCObjectPropertyDatatype dt on
                dt.ID = p.FCObjectPropertyDatatypeID
    where
        p.InValidCharAt = 0
  
)
,
FCEvents as
(
    select
        EventName = cast(e.EventName as nvarchar(max))
        ,RowNr = ROW_NUMBER() over (order by EventName)
    from
    (
        values
            (N''FCObject_Deleted'')
            ,(N''FCObject_Deleting'')
            ,(N''FCObject_Inserted'')
            ,(N''FCObject_Inserting'')
            ,(N''FCObject_UnDeleted'')
            ,(N''FCObject_UnDeleting'')
            ,(N''FCObject_Updated'')
            ,(N''FCObject_Updating'')
          
    ) e(EventName)
    where
        e.EventName like @EventFilter
)
select
    @EventValidationUpdate =
    CAST(
N''delete from ' + @INSIKT_SYS + N'.dbo.EventValidation where FCObjectTypeID = '' + CAST(fcObjectType.ID as nvarchar(12))  + '' and EventName like '''''' + REPLACE(@EventFilter, N'''''''', N'''''''''''') + N'''''';
insert into ' + @INSIKT_SYS + N'.dbo.EventValidation(EventName, SQLQuery, FCObjectTypeID)''  as nvarchar(max))
+
(
select N''
'' +    IIF(e.RowNr > 1, N''union all '', N'''') + N''select
    EventName = '''''' + e.EventName + N''''''
    ,SQLQuery = ''''exec '' + QUOTENAME(DB_NAME()) +  N''.[insikt].''+ quotename(N''FCObject_EventValidation_'' + fcObjectType.Name) + N''
    @EventName = '''''''''' + e.EventName + ''''''''''
    ,@FCObjectID = @FCObjectID
    ,@FCVersionID = @FCVersionID
    ,@ElementKey = @ElementKey
    ,@UserID = @UserID''
    +
    (
    select N''
    ,'' + p.ParameterName + N'' = '' +  p.ParameterName
    from
        FCPropertyParameter p
    where
        p.FCObjectTypeID = fcObjectType.ID
    FOR XML PATH, TYPE
    ).value(N''.[1]'', N''nvarchar(max)'')
    + N''''''
    ,FCObjectTypeID = '' + CAST(fcObjectType.ID as nvarchar(12))
from
    FCEvents e
FOR XML PATH, TYPE
).value(N''.[1]'', N''nvarchar(max)'')
  
    ,@EventHandlerProc =
N''
--
-- Eventhantering för FCObject: '' + fcObjectType.Name + N''
--
  
-- Stubbkod för denna procedur är genererad via:
/*
exec app.Support_Generate_FCObjectEvent ''''' + @INSIKT_SYS + N''''', '' + cast(fcObjectType.ID as nvarchar(max)) + N''
*/
create procedure [insikt].'' + quotename(N''FCObject_EventValidation_'' + fcObjectType.Name) + N''
(
    @EventName nvarchar(50)
    ,@FCObjectID int
    ,@FCVersionID int = NULL
    ,@ElementKey nvarchar(50) = NULL
    ,@UserID int = NULL'' +
      
    (
    select N''
    ,'' + p.ParameterName + N'' '' +  p.SqlDataType + N'' = NULL''
    from
        FCPropertyParameter p
    where
        p.FCObjectTypeID = fcObjectType.ID
    FOR XML PATH, TYPE
    ).value(N''.[1]'', N''nvarchar(max)'')
    +
    N'',@ParentEventID int = null
)
as
  
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
    declare @LogDescription nvarchar(max)
    select @LogDescription =
        ''''@EventName = '''''''''''' + @EventName + ''''''''''''''''
        + iif(@FCObjectID is null, N'''''''', N'''', @FCObjectID = '''' + cast(@FCObjectID as nvarchar(max)))
        + iif(@FCVersionID is null, N'''''''', N'''', @FCVersionID = '''' + cast(@FCVersionID as nvarchar(max)))
        + iif(@ElementKey is null, N'''''''', N'''', @ElementKey = '''''''''''' + cast(@ElementKey as nvarchar(max))) + ''''''''''''''''
        + iif(@UserID is null, N'''''''', N'''', @UserID = '''' + cast(@UserID as nvarchar(max)))'' +
        (
        select N''
        + iif('' + p.ParameterName + N'' is null, N'''''''', N'''', '' + p.ParameterName + N'' = '''' + '' + p.ToEventMessageStr + N'')''
        from
            FCPropertyParameter p
        where
            p.FCObjectTypeID = fcObjectType.ID
        FOR XML PATH, TYPE
        ).value(N''.[1]'', N''nvarchar(max)'')
    +
    N''
  
    exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
            ,@EventTitle = '''''' + replace(fcObjectType.Name, '''''''', '''''''''''') +  ''''''
            ,@Description = @LogDescription
  
    declare
        @Status int = 1
        ,@Message nvarchar(max) = ''''OK''''
  
      
    if @EventName like ''''%ing''''
        begin
            --
            -- Chaging
            --
            print ''''FCObject is about to be changed (or created)''''
 
            /*
            --
            -- Verifiera så att dubletter inte finns
            --
            if exists
            (          
                select 1
                from
                    dbo.FCObject_'' + replace(fcObjectType.Name, '' '', ''_'') + ''_'' + case when fcObjectType.IsStandAlone = 0 then ''Element'' else '''' end + ''View
                where
                    <Kolumn som anses vara primärnyckel> = @<Kolumn som anses vara primärnyckel>
                    and FCObjectID <> @FCObjectID
            )
                select
                     @Status = -1
                    ,@Message = ''''Kombinationen finns redan (den kan vara avaktiverad).''''
            */
        end
    else if @EventName like ''''%ed''''
        begin
            --
            -- Changed
            --
            print ''''FCObject is changed (or created)''''' +
            ISNULL(@SyncToDimensionPartSnippet, N'') + N'
        end
      
  
    SELECT
        Status = @Status
        ,Message = @Message
  
    exec app.LogEventStop @EventIDStack = @EventIDStack out
    --------------------------------------------------------------------------
    -- Stop
    --------------------------------------------------------------------------
end try
begin catch
    --
    -- Roll back any transactions and log errors
    --
    if @TranCount = 0 and @@trancount > 0 rollback tran
    exec app.HandleProcError @EventIDStack out, @ParentEventID, @ProcName
    exec app.ReThrowError
end catch
  
''
from
    ' + @INSIKT_SYS + N'.dbo.FCObjectType fcObjectType
where
    fcObjectType.ID = @FCObjectTypeID
'
  
 declare @DynSQLParams nvarchar(max) = '@FCObjectTypeID int, @EventFilter nvarchar(max), @EventValidationUpdate nvarchar(max) output, @EventHandlerProc nvarchar(max) output '
 exec sys.sp_executesql
    @stmt = @DynSQL
    ,@params = @DynSQLParams
    ,@FCObjectTypeID = @FCObjectTypeID
    ,@EventFilter = @EventFilter
    ,@EventValidationUpdate = @EventValidationUpdate output
    ,@EventHandlerProc =  @EventHandlerProc output
print '--'
print '-- Lägg till event i EventValidation'
print '--'
exec app.PrintMax @EventValidationUpdate
print 'GO'
print ''
print ''
print '--'
print '-- Stubbe med rätt parametrar, loggning och felhantering som är bra att utgå ifrån.'
print '--'
print 'GO'
exec app.PrintMax @EventHandlerProc
print 'GO'
end try
begin catch
    throw;
end catch
GO
