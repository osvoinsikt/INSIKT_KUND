SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[ETL_DimensionPart_FCProject]
(
    @Type nvarchar(4000) = null
    ,@ParamList nvarchar(4000) = null
    ,@ParentEventID int = null
    ,@ChangeUser nvarchar(max) = '[dbo].[ETL_DimensionPart_FCProject]'
    ,@FCProjectID int = null
    ,@FCTypeID int = 2
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
    --------------------------------------------------------------------------
    -- Start
    --------------------------------------------------------------------------
    exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
            ,@EventTitle = 'ETL Dimension Part: FCProject'
            ,@Description = ''

	declare @Incupdate int = app.CheckParamType(isnull(@Type, 'Full'), 'Incupdate')

    drop table if exists #FCProject_SourceData
    drop table if exists #FCProjectID

    create table #FCProject (ID int primary key not null)

    declare @dynSQL nvarchar(max) = N'
        insert into #FCProject
        (
            [ID]
        )
        select
            [ID] = fcp.ID
        from INSIKT_KUND_SYS.[dbo].[FCProject] fcp'

    if @FCProjectID is not null
    begin
        set @dynSQL += N'
        where
            fcp.[ID] = @FCProjectID
            or fcp.[ParentProjectID] = @FCProjectID'
    end
    else
    begin
        set @dynSQL += N'
        where
            fcp.[FCTypeID] = @FCTypeID'
    end

    exec sp_executesql
        @dynSQL,
        N'@FCProjectID int, @FCTypeID int',
        @FCProjectID = @FCProjectID,
        @FCTypeID = 2

    select
        *
    into #FCProject_SourceData
    --select *
    from dw.base_FCProject_FCProjectSource s
        inner join #FCProject p on
            s.FCProjectID = p.ID

    declare @TargetFilter nvarchar(max) = N''
            ,@RowsAffected int = 0

    if(@FCProjectID is not null)
    begin
        select @TargetFilter =
            'exists (
                select 1
                from #FCProject sync_src
                where
                    sync_src.[ID] = [dw].[base_FCProject].[FCProjectID]
            )'
    end

    exec @RowsAffected = app.SyncTable
        @SourceTable = '#FCProject_SourceData'
        ,@TargetTable = '[dw].[base_FCProject]'
        ,@DeleteMode = 1
        ,@DeleteColumn = '_DoNotUseNormalIsDeletedBehaviourToForceSyncWithSourceIsDeletedColumn_'
        ,@TargetFilter = @TargetFilter
        ,@SynchronizedBy = @ChangeUser
        ,@Debug = @Debug

    declare @descriptionText nvarchar(max) =
        concat_ws(', ',
            case when @IncUpdate = 0 and @FCProjectID is null
                then 'Full'
                when @IncUpdate = 1
                then 'IncUpdate'
                when @FCProjectID is not null
                then concat('FCProjectID = ', @FCProjectID)
                else ''
            end
        ,concat('FCTypeID = ', @FCTypeID)
        ,concat('Rows affected = ', @RowsAffected))

    if(@RowsAffected > 0)
    begin
        insert into dbo.FCProject_TriggerIncUpdateEvent (TriggerEvent_INSIKTProjekt)
        values(1)
    end

    exec app.LogEventStop @EventIDStack = @EventIDStack out, @Description = @descriptionText
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

GO
