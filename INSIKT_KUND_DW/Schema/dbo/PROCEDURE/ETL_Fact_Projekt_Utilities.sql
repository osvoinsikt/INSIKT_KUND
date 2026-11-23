SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\dbo\PROCEDURE\ETL_Fact_Projekt_Utilities.sql -----START
-- ==========================================================================================
--
--
-- ==========================================================================================
CREATE procedure [dbo].[ETL_Fact_Projekt_Utilities]
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
	exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
			,@EventTitle = 'ETL Fact Projekt Utilities'
			,@Description = ''

    declare @IncUpdate int = app.CheckParamType(isnull(@Type, 'Full'), 'Incupdate')
	if @IncUpdate = 1
	begin
		set @DisableCDCTrigger = 0
	end

    create table #Combo
    (
        [FCProjectID] int
		,[FCVersionID] int
        ,primary key
        (
            [FCProjectID]
			,[FCVersionID]
        )
    )

    ;with SourceCombos as
	(
        select distinct
            [FCProjectID] = calcProcess.FCProjectID
            ,[FCVersionID] = calcProcess.FCVersionID
        from insikt.FCProject_Versions_CalcProcess calcProcess
        where
            calcProcess.ProcessIsWriteEnabled = 1
            and (@FCProjectID is null or calcProcess.FCProjectID = @FCProjectID)
	)
    ,EventTrigger as
	(
		select distinct
			[FCProjectID] = f.FCProjectID
            ,[FCVersionID] = calcProcess.FCVersionID
		from dbo.FCProject_TriggerIncUpdateEvent_TriggerEvent_Utilities f
            inner join insikt.FCProject_Versions_CalcProcess calcProcess on
                calcProcess.FCProjectID = f.FCProjectID
        where
            calcProcess.ProcessIsWriteEnabled = 1
	)

    insert into #Combo
    (
        [FCProjectID]
        ,[FCVersionID]
    )
    select
        [FCProjectID] = src.FCProjectID
        ,[FCVersionID] = src.FCVersionID
    from SourceCombos src
    where
        @IncUpdate = 0
    union
    select
        [FCProjectID] = et.FCProjectID
        ,[FCVersionID] = et.FCVersionID
    from EventTrigger et
    where
        @IncUpdate = 1

    ;with FCProjectLastUtfallMonth as
    (
        select
            [FCProjectID] = f.FCProjectID
            ,[FCVersionID] = f.FCVersionID
            ,[MonthID] = MAX(f.MonthID)
        from #Combo combo
            inner join dw.fact_Projekt_Utfall_Fryst f on 
                f.FCProjectID = combo.FCProjectID
                and f.FCVersionID = combo.FCVersionID
        group by
            f.FCProjectID
            ,f.FCVersionID
    )

	select
		[FCProjectID] = combo.FCProjectID
		,[FCVersionID]  = combo.FCVersionID
		,[PrevFCVersionID] = calcProcess.PrevFCVersionID
		,[StartMonthID] = fcp.StartMonthID 
		,[StartWritabilityMonthID] = iif(fcp.StartMonthID > app.MonthID(app.GetDateID(GETDATE())),fcp.StartMonthID, app.MonthID(app.GetDateID(dateadd(mm, 1, GETDATE()))))
		-- SQL Server 2022+ kan lösa det med greatest
		-- ,[FCProjectStartWritabilityMonthID] = GREATEST(fcp.StartMonthID,app.MonthID(app.GetDateID(dateadd(mm, 1, GETDATE()))))
		,[EndMonthID] = fcp.EndMonthID
		,[LastUtfallMonthID] = lu.MonthID
	into #fact_Projekt_Utilities
	from #Combo combo
		inner join dw.base_FCProject fcp on 
			fcp.FCProjectID = combo.FCProjectID
        inner join insikt.FCProject_Versions_CalcProcess calcProcess on
            calcProcess.FCProjectID = combo.FCProjectID
            and calcProcess.FCVersionID = combo.FCVersionID
		left join FCProjectLastUtfallMonth lu on
			lu.FCProjectID = combo.FCProjectID
			and lu.FCVersionID = combo.FCVersionID

	--
    -- Om proceduren körs i fullständig omladdning så disablar vi cdc-triggern
    -- Process Full kommer köras i fullständig omladdning
    --
    -- Vid behov att köra fullständig omladdning med hjälp av cdc, kör etl med @DisableCDCTrigger = 0
    --
	if @DisableCDCTrigger = 1
	begin
		exec sys.sp_set_session_context 
			@key = N'Disable:fact_Projekt_Utilities_FactCDC', 
			@value = 1; -- 1 = Disable; NULL/0 = Enabled
	end

    declare @TargetFilter nvarchar(4000) = 
        'exists (
            select 1 
            from #Combo src
            where
                src.FCProjectID = dw.fact_Projekt_Utilities.FCProjectID
                and src.FCVersionID = dw.fact_Projekt_Utilities.FCVersionID
            )'

	exec app.SyncTable
		@SourceTable = '#fact_Projekt_Utilities'
		,@TargetTable = 'dw.fact_Projekt_Utilities'
		,@DeleteMode = 1
		,@TargetFilter = @TargetFilter
	
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


------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\dbo\PROCEDURE\ETL_Fact_Projekt_Utilities.sql -----END


GO
