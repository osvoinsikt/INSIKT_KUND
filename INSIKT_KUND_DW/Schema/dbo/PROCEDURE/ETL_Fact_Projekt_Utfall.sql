SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Author:		twoday INSIKT
-- Description:	Procedur för att ladda projektutfall
-- ==========================================================================================

create procedure [dbo].[ETL_Fact_Projekt_Utfall]
(
	@Type nvarchar(4000) = null
	,@ParamList nvarchar(4000) = null
	,@ParentEventID int = null
	,@FCProjectID int = null
	,@DisableCDCTrigger bit = 1
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
	declare @descriptionText nvarchar(max) = concat('FCProjectID (', coalesce(convert(varchar(max), @FCprojectID), '<All>'),')')

	exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
			,@EventTitle = 'ETL_Fact_Projekt_Utfall'
			,@Description = @descriptionText

	declare @IncUpdate int = [app].[CheckParamType] (isnull(@Type, 'Full'), 'Incupdate')
	if @IncUpdate = 1
	begin
		set @DisableCDCTrigger = 0
	end

    create table #Combo
    (
        [FCProjectID] int
        ,primary key
        (
            [FCProjectID]
        )
    )

    ;with SourceCombos as
    (
        select distinct
            [FCProjectID] = f.FCProjectID
        from dw.fact_Projekt_Utfall_SourceView f
        where
            (@FCProjectID is null or f.FCProjectID = @FCProjectID)
    )
    ,EventTrigger as
    (
        select distinct
            [FCProjectID] = u.FCProjectID
        from dbo.FCProject_TriggerIncUpdateEvent_TriggerEvent_Utfall u
    )

    insert into #Combo
    (
        [FCProjectID]
    )
    select
        [FCProjectID] = f.FCProjectID
    from SourceCombos f
    where
        @IncUpdate = 0
    union
    select
        [FCProjectID] = et.FCProjectID
    from EventTrigger et
    where
        @IncUpdate = 1

	select
		f.*
	into #fact_Projekt_Utfall
		--select *
	from dw.fact_Projekt_Utfall_SourceView f
		inner join #Combo c on
			c.FCProjectID = f.FCProjectID

    --
    -- Om proceduren körs i fullständig omladdning så disablar vi cdc-triggern
    -- Process Full kommer köras i fullständig omladdning
    --
    -- Vid behov att köra fullständig omladdning med hjälp av cdc, kör etl med @DisableCDCTrigger = 0
    --
	if @DisableCDCTrigger = 1
	begin
		exec sys.sp_set_session_context
			@key = N'Disable:fact_Projekt_Utfall_FactCDC',
			@value = 1; -- 1 = Disable; NULL/0 = Enabled
	end

	exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
		,@EventTitle = '[app].[SyncTable]'
		,@Description = null -- Beskrivning sätts efteråt med antal rader

	--
	--	Säkerställ att alla projekt som synkroniseras filtreras ut i @TargetTable via @TargetFilter
	--	Detta säkerställer att vi endast tar bort rader kopplat till våran källas FCProjectID (dvs ej längre giltiga kombinationer som t.ex. felaktigt kopplat projektnummer osv)
	--
	declare @TargetFilter nvarchar(1000) = 'exists (select 1 from #Combo src where src.FCProjectID = dw.fact_Projekt_Utfall.FCProjectID)'

	declare @RowsAffected int = 0
	exec @RowsAffected = app.SyncTable
		@SourceTable = '#fact_Projekt_Utfall'
		,@TargetTable = 'dw.fact_Projekt_Utfall'
		,@TargetFilter = @TargetFilter
		,@DeleteMode = 1 --1 = Borttagna rader raderas, 2 = Borttagna rader markeras som borttagna via flaggan IsDeleted,  3 = Borttagna lämnas kvar (endast insert/update)
		,@Debug = 0

	declare @RowsAffectedDescription nvarchar(max) = concat('Rows updated: ', @RowsAffected)
	exec app.LogEventStop @EventIDStack = @EventIDStack out, @Description = @RowsAffectedDescription

	exec app.LogEventStop @EventIDStack = @EventIDStack out
	--------------------------------------------------------------------------
	-- Stop
	--------------------------------------------------------------------------

end try
begin catch
	--
	-- Rulla tillbaka eventualla transaktioner startade i den här proceduren och logga fel.
	--
	if @TranCount = 0 and @@trancount > 0 rollback tran
	exec app.HandleProcError @EventIDStack out, @ParentEventID, @ProcName
	exec app.ReThrowError
end catch


GO
