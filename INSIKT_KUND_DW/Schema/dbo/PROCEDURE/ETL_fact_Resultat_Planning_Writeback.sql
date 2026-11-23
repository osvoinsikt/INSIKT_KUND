SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================================
-- Author:		TRIMMA Affärsutveckling AB
-- Description:	Procedur för att ladda hierarkier
-- ==========================================================================================
-- LOG:
--	2013-03-26, TRIMMA	Standardimplementation
-- ==========================================================================================
create procedure [dbo].[ETL_fact_Resultat_Planning_Writeback]
(
	@Type nvarchar(4000) = null
	,@ParamList nvarchar(4000) = null	
	,@ParentEventID int = null
	,@PlanningVersionID int = null
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
			,@EventTitle = 'ETL [dw].[fact_Resultat_Planning]'
			,@Description = 'Hantera writeback data'


		create table #PlanningVersion_OpenPlanningVersions
		(
			PlanningVersionID int not null primary key
		)
		insert into #PlanningVersion_OpenPlanningVersions
		(
			PlanningVersionID
		)
		select
			PlanningVersionID					
		from
			dw.dim_PlanningVersion pv
		where
			(
				(
					isnull(pv.IsBudget, 0) = 1
					or isnull(pv.OpenForSuperUsers, 0) = 1
				)
				and @PlanningVersionID is null				
			)
			or
			pv.PlanningVersionID = @PlanningVersionID


		--
		-- Ta bort stängda planeringsversioner från writebackpartitionen
		--
		if @TranCount = 0 begin tran;

		--
		-- Dum fråga för att säkerställa TABLOCK på hela writebacktabellen.
		--
		select top 0 * into #Dummy from [dbo].[WriteTable_fact_Resultat_Planning_WithTrigger] with (TABLOCKX, HOLDLOCK);

		declare 
			@WbCount int
			,@FactCount int
		--
		-- Ta bort data för stängda planeringsversioner
		--
		delete from	[dbo].[WriteTable_fact_Resultat_Planning_WithTrigger] 
		where
			PlanningVersionID_3 not in (select PlanningVersionID from #PlanningVersion_OpenPlanningVersions);
		--
		-- Antal borttagna rader från writeback
		--
		set @WbCount = @@ROWCOUNT;

		--
		-- Updatera Flagga i faktatabell för rader som nu tagits bort i writebacktabell.
		--
		update [dw].[fact_Resultat_Planning] set
			ExistsInWriteTable = 0
		where
			ExistsInWriteTable = 1
			and PlanningVersionID not in (select PlanningVersionID from #PlanningVersion_OpenPlanningVersions)

		--
		-- Antal rader i faktatabell som fått ExistsInWritetable-flagga uppdaterad.
		--
		set @FactCount = @@ROWCOUNT

		--
		-- Antal rader i wb och fact måste vara exakt samma.
		--
		if @FactCount <> @WbCount
			raiserror('Nr of rows in writeback missmatch with rows in fact.', 16, 10)

		if @TranCount = 0 commit tran

	exec app.LogEventStop @EventIDStack = @EventIDStack out
	-- Stop
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

GO
