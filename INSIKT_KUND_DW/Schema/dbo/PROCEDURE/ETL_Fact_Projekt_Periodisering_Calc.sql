SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[ETL_Fact_Projekt_Periodisering_Calc]
(
    @Type nvarchar(4000) = null
    ,@ParamList nvarchar(4000) = null
    ,@ParentEventID int = null
    ,@FCProjectID int = null
	,@FCVersionID int = null
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
    exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output
            ,@EventObject = @ProcName
            ,@EventTitle = 'ETL_Fact_Project_Periodisering_Calc'
            ,@Description = 'Räknar om periodisering'

	declare @Incupdate int = app.CheckParamType(isnull(@Type, 'Full'), 'Incupdate')
    if @Incupdate = 1
    begin
        set @DisableCDCTrigger = 0
    end

    create table #Combo
    (
        [FCProjectID] int
        ,[FCVersionID] int
        ,[KontoID] int
        ,primary key
        (
            [FCProjectID]
            ,[FCVersionID]
            ,[KontoID]
        )
    )

    ;with SourceCombos as
    (
        select
            [FCProjectID] = f.FCProjectID
            ,[FCVersionID] = f.FCVersionID
            -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
            ,[KontoID] = f.KontoID
        from dw.fact_Projekt_Periodisering_Planning_Underlag_Kalkyl f
            inner join insikt.FCProject_Versions_CalcProcess calcprocess on
                calcprocess.FCProjectID = f.FCProjectID
                and calcprocess.FCVersionID = f.FCVersionID
        where
            calcprocess.[ProcessIsWriteEnabled] = 1
            and (@FCProjectID is null or calcprocess.FCProjectID = @FCProjectID)

        union
        select
            [FCProjectID] = f.FCProjectID
            ,[FCVersionID] = f.FCVersionID
            -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
            ,[KontoID] = f.KontoID
        from dw.fact_Projekt_Utfall_Fryst f
            inner join insikt.FCProject_Versions_CalcProcess calcprocess on
                calcprocess.FCProjectID = f.FCProjectID
                and calcprocess.FCVersionID = f.FCVersionID
        where
            calcprocess.[ProcessIsWriteEnabled] = 1
            and (@FCProjectID is null or calcprocess.FCProjectID = @FCProjectID)
    )
    ,EventTrigger as
    (
        select distinct
            [FCProjectID] = triggerEvent.FCProjectID
            ,[FCVersionID] = triggerEvent.FCVersionID
            -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
            ,[KontoID] = src.KontoID
        from dbo.FCProject_TriggerIncUpdateEvent_TriggerEvent_Periodisering triggerEvent
            inner join SourceCombos src on
                src.FCProjectID = triggerEvent.FCProjectID
                and src.FCVersionID = triggerEvent.FCVersionID
    )
    ,IncUpdate as
    (
        select
            [FCProjectID] = kalkyl.FCProjectID
            ,[FCVersionID] = kalkyl.FCVersionID
            -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
            ,[KontoID] = kalkyl.KontoID
        from dw.fact_Projekt_Periodisering_Planning_Underlag_Kalkyl kalkyl
        where
            kalkyl.[NrOfIncUpdateRows] > 0

        union
        select
            [FCProjectID] = periodisering.FCProjectID
            ,[FCVersionID] = periodisering.FCVersionID
            -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
            ,[KontoID] = periodisering.KontoID
        from dw.fact_Projekt_Periodisering_Planning_Underlag_Periodisering periodisering
        where
            periodisering.NrOfIncUpdateRows > 0

        union
        select
            [FCProjectID] = manuella.FCProjectID
            ,[FCVersionID] = manuella.FCVersionID
            -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
            ,[KontoID] = manuella.KontoID
        from dw.fact_Projekt_Periodisering_Planning_Underlag_ManuellaMånader manuella
        where
            manuella.[NrOfIncUpdateRows] > 0

        union
        select
            [FCProjectID] = metod.FCProjectID
            ,[FCVersionID] = metod.FCVersionID
            -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
            ,[KontoID] = metod.KontoID
        from dw.fact_Projekt_Periodisering_Planning_Underlag_Metod metod
        where
            metod.[NrOfIncUpdateRows] > 0

        union
        select
            [FCProjectID] = f.FCProjectID
            ,[FCVersionID] = f.FCVersionID
            -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
            ,[KontoID] = f.KontoID
        from dw.fact_Projekt_Utfall_Fryst_FactCDC f
    )

    insert into #Combo
    (
        [FCProjectID]
        ,[FCVersionID]
        ,[KontoID]
    )
    select
        [FCProjectID] = f.FCProjectID
        ,[FCVersionID] = f.FCVersionID
        -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
        ,[KontoID] = f.KontoID
    from
        SourceCombos f
    where
        @Incupdate = 0

    union
    select
        [FCProjectID] = et.FCProjectID
        ,[FCVersionID] = et.FCVersionID
        -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
        ,[KontoID] = et.KontoID
    from EventTrigger et
    where
        @Incupdate = 1

    union
    select
        [FCProjectID] = inc.FCProjectID
        ,[FCVersionID] = inc.FCVersionID
        -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
        ,[KontoID] = inc.KontoID
    from IncUpdate inc
    where
        @Incupdate = 1

    select
        [FCProjectID] = periodiseringsunderlag.FCProjectID
        ,[FCVersionID] = periodiseringsunderlag.FCVersionID
        ,[KontoID] = periodiseringsunderlag.KontoID
        ,[Rest] = periodiseringsunderlag.Rest
        ,[AntalManuellaMånader] = periodiseringsunderlag.AntalManuellaMånader
        ,[StartMonthID] = periodiseringsunderlag.StartMonthID
        ,[EndMonthID] = periodiseringsunderlag.EndMonthID
        ,[NrOfMonths] =
            app.DateDiffMonth(periodiseringsunderlag.StartMonthID * 100 + 1, periodiseringsunderlag.EndMonthID * 100 + 1) + 1 - periodiseringsunderlag.AntalManuellaMånader
    into #periodiseringsunderlag
    from
    (
        select
            [FCProjectID] = combo.FCProjectID
            ,[FCVersionID] = combo.FCVersionID
            -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
            ,[KontoID] = combo.KontoID
            -- Om periodiseringsmetod är manuell ska rest vara 0 för att kunna räkna bort periodisering
            ,[Rest] = iif(metod.PeriodiseringsMetod = 'Manuell', 0, isnull(kalkyl.Kalkyl, 0) - isnull(periodisering.PeriodiseratBelopp, 0) - isnull(utfall.Amount,0))
            ,[AntalManuellaMånader] = isnull(periodisering.AntalManuellaMånader, 0) --  Om variabeln för exkludering är satt undantas månader med manuell periodisering
            ,[StartMonthID] =
            (
                select max(MonthID)
                from
                    (
                    values
                        (fcp.StartMonthID) -- Projektets startmånad
                        ,(app.MonthID(app.DateAddMonth(utilities.LastUtfallMonthID * 100 + 1, 1))) -- Senaste utfallsmånaden + 1
                        ,(utilities.StartWritabilityMonthID) --Innevarande månad
                        ,(metod.StartMonthID) -- Metodens startmånad
                    ) as m (MonthID)
            )
            ,EndMonthID =
            (
                select min(MonthID)
                from
                    (
                    values
                        (fcp.EndMonthID) -- Projektets slutmånad
                        ,(nullif(metod.EndMonthID, 0)) -- Metodens slutmånad
                    ) as m (MonthID)
            )
        from #Combo combo
            inner join dw.base_FCProject fcp on
                fcp.FCProjectID = combo.FCProjectID
            inner join dw.fact_Projekt_Utilities utilities on
                utilities.FCProjectID = combo.FCProjectID
                and utilities.FCVersionID = combo.FCVersionID
            left join dw.fact_Projekt_Periodisering_Planning_Underlag_Kalkyl kalkyl on
                kalkyl.FCProjectID = combo.FCProjectID
                and kalkyl.FCVersionID = combo.FCVersionID
                -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
                and kalkyl.KontoID = combo.KontoID
            left join dw.fact_Projekt_Periodisering_Planning_Underlag_Utfall utfall on
                utfall.FCProjectID = combo.FCProjectID
                and utfall.FCVersionID = combo.FCVersionID
                -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
                and utfall.KontoID = combo.KontoID
            left join dw.fact_Projekt_Periodisering_Planning_Underlag_Periodisering periodisering on
                periodisering.FCProjectID = combo.FCProjectID
                and periodisering.FCVersionID = combo.FCVersionID
                -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
                and periodisering.KontoID = combo.KontoID
            left join dw.fact_Projekt_Periodisering_Planning_Underlag_Metod metod on
                metod.FCProjectID = combo.FCProjectID
                and metod.FCVersionID = combo.FCVersionID
                -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
                and metod.KontoID = combo.KontoID
    ) periodiseringsunderlag
    where
        nullif(periodiseringsunderlag.EndMonthID, 0) is not null
        and nullif(periodiseringsunderlag.StartMonthID, 0) is not null

    select
        [FCProjectID] = f.FCProjectID
        ,[FCVersionID] = f.FCVersionID
        ,[MonthID] = t.MonthID
        -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
        ,[KontoID] = f.KontoID
        ,[BeräknatPeriodiseratBelopp] = f.Rest * 1e0 / f.NrOfMonths
    into #fact_Projekt_Periodisering_Planning
    from #periodiseringsunderlag f
        inner join dw.dim_Planeringsperiod_Projekt t on
            t.MonthID >= f.StartMonthID
            and t.MonthID <= f.EndMonthID
        left join dw.fact_Projekt_Periodisering_Planning_Underlag_ManuellaMånader mm on
            mm.FCProjectID = f.FCProjectID
            and mm.FCVersionID = f.FCVersionID
            and mm.MonthID = t.MonthID
            -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
            and mm.KontoID = f.KontoID
    where
        mm.MonthID is null
        and f.NrOfMonths > 0

    -- Ifall vi har en återstående rest som inte kunnat periodiseras (t.ex. pga. 0 månader att periodisera på)
    -- så periodiseras denna på sista månaden
    union all
    select
        [FCProjectID] = f.FCProjectID
        ,[FCVersionID] = f.FCVersionID
        ,[MonthID] = t.MonthID
        -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
        ,[KontoID] = f.KontoID
        ,[BeräknatPeriodiseratBelopp] = f.Rest * 1e0
    from #periodiseringsunderlag f
        inner join dw.dim_Planeringsperiod_Projekt t on
            t.MonthID = f.EndMonthID
    where
        f.NrOfMonths <= 0

    declare @RowsAffected int = 0
	exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
		,@EventTitle = '[app].[SyncTable]'
		,@Description = null -- Beskrivning sätts i efterföljande kod

    --
    -- Om proceduren körs i fullständig omladdning så disablar vi cdc-triggern
    -- Process Full kommer köras i fullständig omladdning
    --
    -- Vid behov att köra fullständig omladdning med hjälp av cdc, kör etl med @DisableCDCTrigger = 0
    --
    if @DisableCDCTrigger = 1
    begin
        exec sys.sp_set_session_context
            @key = N'Disable:fact_Projekt_Periodisering_Planning_Calc_FactCDC',
            @value = 1; -- 1 = Disable; NULL/0 = Enabled
    end

    -- Säkerställ att alla projekt som synkroniseras filtreras ut i @TargetTable via @TargetFilter
    -- Detta säkerställer att vi endast tar bort rader kopplat till våran källas FCProjectID och FCVersionID
    -- declare @IncUpdate int = 1
    declare @TargetFilter nvarchar(4000) =
        'exists(
            select 1
            from
                #Combo src
            where
                src.FCProjectID = dw.fact_Projekt_Periodisering_Planning_Calc.FCProjectID
                and src.FCVersionID = dw.fact_Projekt_Periodisering_Planning_Calc.FCVersionID
				'
                +
                iif(
                    @Incupdate = 1
                    -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
                    ,'and src.KontoID = dw.fact_Projekt_Periodisering_Planning_Calc.KontoID'
                    ,''
                )
                + '
            )'

    exec @RowsAffected = [app].[SyncTable]
        @SourceTable = '#fact_Projekt_Periodisering_Planning'
        ,@TargetTable = '[dw].[fact_Projekt_Periodisering_Planning_Calc]'
        ,@TargetFilter = @TargetFilter
        ,@DeleteMode = 1
        ,@SupressWarnings = 1
        ,@Debug = 0

    declare @RowsAffectedDescription nvarchar(max) = concat('Rows updated: ', @RowsAffected)
    exec app.LogEventStop @EventIDStack = @EventIDStack out, @Description = @RowsAffectedDescription

	if @RowsAffected > 0
	begin
		if @Incupdate = 1
		begin
			--Används för att vänta på OnCubeUpdated
			insert into [dbo].[FCproject_TriggerIncUpdateEvent]
			(
			   [WaitForEvents]
			)
			values(1)
		end
	end

    exec app.LogEventStop @EventIDStack = @EventIDStack out
    --------------------------------------------------------------------------
end try
begin catch
    --
    -- Rulla tillbaka eventualla transaktioner startade i den här procedurn och logga fel.
    --
    if @TranCount = 0 and @@trancount > 0 rollback tran
    exec app.HandleProcError @EventIDStack out, @ParentEventID, @ProcName
    exec app.ReThrowError
end catch

------- INSIKT_DW\dw\PROCEDURE\ETL_Fact_Projekt_Periodisering_Calc.sql -----END




------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\dbo\PROCEDURE\ETL_Fact_Projekt_Periodisering_Calc.sql -----END


GO
