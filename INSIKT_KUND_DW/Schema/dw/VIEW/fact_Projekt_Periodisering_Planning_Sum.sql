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
create view [dw].[fact_Projekt_Periodisering_Planning_Sum] as
SELECT
    [FCProjectID] = f.[FCProjectID]
    ,[FCVersionID] = f.[FCVersionID]
    ,[MonthID] = f.[MonthID]
    ,[KontoID] = f.[KontoID]
    ,[PeriodiseratBelopp] = f.[PeriodiseratBelopp]
    ,[FgPeriodiseratBelopp] = f.[FgPeriodiseratBelopp]
    ,[AuditUser] = cast(null as nvarchar(255))
    ,[AuditTime] = cast(null as datetime)
    ,[ExistsInWriteTable] = cast(null as bit)
    ,[NrOfIncUpdateRows] = f.[NrOfIncUpdateRows]
    ,[IncUpdate] = cast(null as bit)
    ,[RowTypeID] = cast(null as smallint)
from
    [dw].[fact_Projekt_Periodisering_Planning_IxSum] f with (noexpand)
GO
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
create  trigger [TR_fact_Projekt_Periodisering_Planning_to_fact_Projekt_Periodisering_Planning_IxSum] on [dw].[fact_Projekt_Periodisering_Planning_Sum]
INSTEAD OF INSERT, UPDATE, DELETE
as
begin
set nocount on
insert into dw.fact_Projekt_Periodisering_Planning
(
    [FCProjectID]
    ,[FCVersionID]
    ,[MonthID]
    ,[KontoID]
    ,[PeriodiseratBelopp]
    ,[FgPeriodiseratBelopp]
    ,[AuditUser]
    ,[AuditTime]
    ,[ExistsInWriteTable]
    ,[IncUpdate]
    ,[RowTypeID]
)
select
    [FCProjectID] = isnull(i.[FCProjectID], d.[FCProjectID])
    ,[FCVersionID] = isnull(i.[FCVersionID], d.[FCVersionID])
    ,[MonthID] = isnull(i.[MonthID], d.[MonthID])
    ,[KontoID] = isnull(i.[KontoID], d.[KontoID])
    ,[PeriodiseratBelopp] = nullif(isnull(i.[PeriodiseratBelopp], 0) - isnull(d.[PeriodiseratBelopp], 0), 0)
    ,[FgPeriodiseratBelopp] = nullif(isnull(i.[FgPeriodiseratBelopp], 0) - isnull(d.[FgPeriodiseratBelopp], 0), 0)
    ,[AuditUser] = coalesce(i.[AuditUser],cast(session_context(N'DEF:[dw].[fact_Projekt_Periodisering_Planning_Sum].[AuditUser]') as nvarchar(255)), suser_name())
    ,[AuditTime] = coalesce(i.[AuditTime],cast(session_context(N'DEF:[dw].[fact_Projekt_Periodisering_Planning_Sum].[AuditTime]') as datetime), getutcdate())
    ,[ExistsInWriteTable] = coalesce(i.[ExistsInWriteTable],cast(session_context(N'DEF:[dw].[fact_Projekt_Periodisering_Planning_Sum].[ExistsInWriteTable]') as bit),((0)))
    ,[IncUpdate] = coalesce(i.[IncUpdate],cast(session_context(N'DEF:[dw].[fact_Projekt_Periodisering_Planning_Sum].[IncUpdate]') as bit),((0)))
    ,[RowTypeID] = coalesce(i.[RowTypeID],cast(session_context(N'DEF:[dw].[fact_Projekt_Periodisering_Planning_Sum].[RowTypeID]') as smallint))
from
    inserted i
        full join deleted d on
            d.[FCProjectID] = i.[FCProjectID]
            and d.[FCVersionID] = i.[FCVersionID]
            and d.[MonthID] = i.[MonthID]
            and d.[KontoID] = i.[KontoID]
where
    abs( nullif(isnull(i.[PeriodiseratBelopp], 0) - isnull(d.[PeriodiseratBelopp], 0), 0) ) > 0.00001
    or abs( nullif(isnull(i.[FgPeriodiseratBelopp], 0) - isnull(d.[FgPeriodiseratBelopp], 0), 0) ) > 0.00001
end

GO
