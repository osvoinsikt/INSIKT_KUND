SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------
-- OBS!
-------------------------------------------------------------------------------------
-- Denna vy är automatiskt genererad av [app].[FactSumView_Create]
-- Ev. ändringar kan skrivas över.
-------------------------------------------------------------------------------------
--
-- Detta är en del av ett ramverk för att underlätta och snabba upp group by/sum av
-- en transaktionsfaktatabell samt att ge möjlighet att generera ändringstransaktioner
-- genom att möjlig göra insert/update på den grupperade vyn.
--
--
-- Ingående objekt för transaktionstabellen: dw.fact_Projekt_Periodisering_Planning
-- * Indexerad vy: [dw].[fact_Projekt_Periodisering_Planning_IxSum]
--       - Index: IX_GrpSum_fact_Projekt_Periodisering_Planning_IxSum
-- * Select/Update-vy med trigger: [dw].[fact_Projekt_Periodisering_Planning_Sum]
--       - Trigger: TR_fact_Projekt_Periodisering_Planning_to_fact_Projekt_Periodisering_Planning_IxSum
--
--
-- På grund av att vyn [dw].[fact_Projekt_Periodisering_Planning_IxSum] är skapad med
-- schemabinding för att möjliggöra skapande av index på den blir det svårt att
-- ändra underliggande tabellstruktur.
--
-- För att tillfälligt ta bort schemabinding och index, använd:
-- exec app.FactSumView_Disable 'dw.fact_Projekt_Periodisering_Planning'
-- exec app.FactSumView_Enable 'dw.fact_Projekt_Periodisering_Planning'
--
-------------------------------------------------------------------------------------
--
-- Kör nedanstående för att återskapa vyn:
--
/*
exec [app].[FactSumView_Create]
    @SourceFactTable = 'dw.fact_Projekt_Periodisering_Planning'
    ,@DimColumns = NULL
    ,@MeasureColumns = NULL
    ,@TargetFactIxView = '[dw].[fact_Projekt_Periodisering_Planning_IxSum]'
	,@TargetFactSumView = '[dw].[fact_Projekt_Periodisering_Planning_Sum]'
*/

-------------------------------------------------------------------------------------
-- Via triggers i Sum-vyn kan diffposter genereras i underliggande faktatabell
-- Alltså via INSERT/UPDATE/DELETE i [dw].[fact_Projekt_Periodisering_Planning_Sum]
--
-- Proceduren app.SyncTable fungerar väldigt bra för att underlätta dessa operation:
-- Ex:
/*
--
-- Sätt defaultvärden på icke-dimensions/measures-kolumner. Dessa sessionsvariabler påverkar sum-vyns-trigger.
-- Om motsvarande kolumn även finns i @SourceTable så används det värdet i första hand (obs! går ej att sätta vid delete).
--

-- Defaultvärde på RowTypeID
exec sys.sp_set_session_context 
	@key = N'DEF:[dw].[fact_Projekt_Periodisering_Planning_Sum].[RowTypeID]',
	@value = 1234;

-- Skapa diffposter i underliggande faktatabell via SyncTable och Sum-vy
exec app.SyncTable
    @TargetTable = '[dw].[fact_Projekt_Periodisering_Planning_Sum]'
    ,@SourceTable= '#fact_Projekt_Periodisering_Planning'
    ,@JoinColumns = '[FCProjectID], [FCVersionID], [MonthID], [KontoID]'

*/
-------------------------------------------------------------------------------------
create view [dw].[fact_Projekt_Periodisering_Planning_IxSum] with schemabinding as
SELECT
    [FCProjectID] = f.[FCProjectID]
    ,[FCVersionID] = f.[FCVersionID]
    ,[MonthID] = f.[MonthID]
    ,[KontoID] = f.[KontoID]
    ,[PeriodiseratBelopp] = sum(isnull(f.[PeriodiseratBelopp], 0))
    ,[FgPeriodiseratBelopp] = sum(isnull(f.[FgPeriodiseratBelopp], 0))
    ,[NrOfIncUpdateRows] = sum(cast(f.[IncUpdate] as int))
    ,[RowCnt] = count_big(*)
from
    dw.fact_Projekt_Periodisering_Planning f
group by
    f.[FCProjectID]
    ,f.[FCVersionID]
    ,f.[MonthID]
    ,f.[KontoID]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
CREATE UNIQUE CLUSTERED INDEX [IX_GrpSum_fact_Projekt_Periodisering_Planning_IxSum] ON [dw].[fact_Projekt_Periodisering_Planning_IxSum]
(
	[FCProjectID] ASC,
	[FCVersionID] ASC,
	[MonthID] ASC,
	[KontoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
