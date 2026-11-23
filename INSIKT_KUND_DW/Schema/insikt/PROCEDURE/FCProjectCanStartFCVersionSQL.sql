SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Author: twoday INSIKT AB
-- Description: Procedur som kan konfigureras att användas i projektmodulen för att avgöra vilka versioner som får skapas 
--              Konfigureras i dbo.FCElementProperty för FCPropertyID = 411
--                ValueNumeric = 1, ValueString = 'INSIKT_KUND_DW.insikt.FCProjectCanStartFCVersionSQL'
-- ==========================================================================================

create procedure [insikt].[FCProjectCanStartFCVersionSQL] (
    @Type nvarchar(4000) = null
    ,@ParamList nvarchar(4000) = null
    ,@ParentEventID int = null
    ,@FCTypeID int
    ,@CompanyID int
    ,@FCProjectID int
    ,@UserID int
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
    -- Bör vi ens logga det här? Onödigt spam som leverantörskonsolen kan ta fram istället
    -- exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
    --     ,@EventTitle = 'ProjectCalcVersionsAbleToStartSQL'
    --     ,@Description = 'ProjectCalcVersionsAbleToStartSQL'

    declare @allProcessesCompleted bit
    select @allProcessesCompleted = AllProcessesCompleted from #CurrentVersionStatus

    -- #CurrentVersionStatus verkar kräva att man har versioner i en utpekad ordningsföljd med fgversion osv, så kommer ej lira med många lösningar
    -- Nedan SQL bör ge ett smidigare förslag på lösning
    declare @nextVersionInLine int
    select @nextVersionInLine = VersionID from #CurrentVersionStatus where IsNextInLine = 1

    if (@allProcessesCompleted = 1)
    begin
        select
            [VersionID] = MAX(fcv.ID)
        from INSIKT_KUND_SYS.dbo.FCVersion fcv
        where
            fcv.Type = 3
            and fcv.PeriodMonth* 100 + 1 <= app.GetDateID(GETDATE())
    end
    else
    begin
        -- Måste klarmarkera samtliga innan vi går vidare
        select
            [VersionID] = null
            ,[CanStart] = 0
            ,[CanNotStartReason] = 'Det finns pågående versioner som behöver klarmarkeras'
    end

    -- exec app.LogEventStop @EventIDStack = @EventIDStack out
    -- Stop
    --------------------------------------------------------------------------

end try
begin catch
    --
    -- Rulla tillbaka eventuella transaktioner startade i den här procedurn och logga fel.
    --
    if @TranCount = 0 and @@trancount > 0 rollback tran
    exec app.HandleProcError @EventIDStack out, @ParentEventID, @ProcName
    exec app.ReThrowError
end catch

------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\insikt\PROCEDURE\FCProjectCanStartFCVersionSQL.sql -----END


GO
