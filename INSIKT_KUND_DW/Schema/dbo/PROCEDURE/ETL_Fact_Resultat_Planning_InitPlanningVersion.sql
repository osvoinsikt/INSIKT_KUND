SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[ETL_Fact_Resultat_Planning_InitPlanningVersion] 
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
			,@EventTitle = 'ETL fact_Resultat_Planning'
			,@Description = 'Initiera planeringsversion'


		declare 
			@PlanningVersionType int	
			,@FirstBudgetDate datetime
			,@FirstBudgetDateID int
			,@SourcePlanningVersionID int
			,@FiscalYearStart datetime
			,@FiscalYearStartID int

		select
			@PlanningVersionType = pv.Type
			,@FirstBudgetDate =
				isnull
				(
					dateadd(month, 1, cast(cast(pv.NrOfLockedPeriods * 100 + 1 + pv.FiscalYear * 10000 as char(8)) as datetime))
					,cast(cast(pv.FiscalYear * 10000 + 101 as char(8)) as datetime)
				)
			,@FiscalYearStart = cast(cast(pv.FiscalYear * 10000 + 101 as char(8)) as datetime)
			,@SourcePlanningVersionID = pv.OriginVersionID
		from
			dw.dim_PlanningVersion pv
		where
			pv.PlanningVersionID = @PlanningVersionID 

		select
			@FirstBudgetDateID = year(@FirstBudgetDate) * 10000 + month(@FirstBudgetDate) * 100 + day(@FirstBudgetDate)
			,@FiscalYearStartID = year(@FiscalYearStart) * 10000 + month(@FiscalYearStart) * 100 + day(@FiscalYearStart)

	
		if @PlanningVersionType = 2 -- Prognoser
			begin
				--
				-- Fyll med utfall för utfallsmånader
				--
				INSERT INTO [dw].[fact_Resultat_Planning]
				(
					[PlanningVersionID]
					,[PostingDateID]
					,[KontoID]
					,[Organisation_LeafID]
					,[AvdelningID]
					,[KampanjID]
					,[ProjektID]
					,[VarugruppID]
					,[PlanningAmount]
					,[PlanningQuantity]
					,[AuditUser]
					,[AuditTime]
					,[ExistsInWriteTable]
					,[IncUpdate]
					,[RowTypeID]
				)
				select 
					[PlanningVersionID] = @PlanningVersionID
					,[PostingDateID] = f.[PostingDateID] - f.[PostingDateID] % 100 + 1
					,[KontoID] = f.[KontoID]
					,[Organisation_LeafID] = f.[Organisation_LeafID]
						
					,[AvdelningID] = f.[AvdelningID]
						
					,[KampanjID] = f.[KampanjID]
						
					,[ProjektID] = f.[ProjektID]
						
					,[VarugruppID] = f.[VarugruppID]
	
					,[PlanningAmount] = sum(f.[Amount])
					,[PlanningQuantity] = sum(f.[Number])
					,[AuditUser] = @ProcName
					,[AuditTime] = getdate()
					,[ExistsInWriteTable] = 0
					,[IncUpdate] = 0
					,[RowTypeID] = f.[RowTypeID]
				from
					[dw].[fact_Resultat] f
						inner join [dw].[dim_Time] t on
							f.[PostingDateID] = t.DateID
				where 
					t.[FiscalDateID] >= @FiscalYearStartID
					and t.[FiscalDateID] < @FirstBudgetDateID
				group by
					f.[PostingDateID] - f.[PostingDateID] % 100 + 1
					,f.[KontoID]
					,f.[Organisation_LeafID]
						
					,f.[AvdelningID]
						
					,f.[KampanjID]
						
					,f.[ProjektID]
						
					,f.[VarugruppID]
	
					,f.[RowTypeID]					


				--
				-- Kopiera budget/prognos
				--
				INSERT INTO [dw].[fact_Resultat_Planning]
				(
					[PlanningVersionID]
					,[PostingDateID]
					,[KontoID]
					,[Organisation_LeafID]
						
					,[AvdelningID]
						
					,[KampanjID]
						
					,[ProjektID]
						
					,[VarugruppID]
	
					,[PlanningAmount]
					,[PlanningQuantity]
					,[AuditUser]
					,[AuditTime]
					,[ExistsInWriteTable]
					,[IncUpdate]
					,[RowTypeID]
				)
				select
					[PlanningVersionID] = @PlanningVersionID
					,[PostingDateID] = f.[PostingDateID]
					,[KontoID] = f.[KontoID]
					,[Organisation_LeafID] = f.[Organisation_LeafID]
						
					,[AvdelningID] = f.[AvdelningID]
						
					,[KampanjID] = f.[KampanjID]
						
					,[ProjektID] = f.[ProjektID]
						
					,[VarugruppID] = f.[VarugruppID]
	
					,[PlanningAmount] = sum(f.[PlanningAmount])
					,[PlanningQuantity] = sum(f.[PlanningQuantity])
					,[AuditUser] = @ProcName
					,[AuditTime] = getdate()
					,[ExistsInWriteTable] = 0
					,[IncUpdate] = 0
					,[RowTypeID] = f.[RowTypeID]
				from
					[dw].[fact_Resultat_Planning] f
						inner join [dw].[dim_Time] t on
							f.[PostingDateID] = t.DateID
				where
					f.PlanningVersionID = @SourcePlanningVersionID
					and t.[FiscalDateID] >= @FirstBudgetDateID
				group by
					f.[PostingDateID]
					,f.[KontoID]
					,f.[Organisation_LeafID]
						
					,f.[AvdelningID]
						
					,f.[KampanjID]
						
					,f.[ProjektID]
						
					,f.[VarugruppID]
					,f.[RowTypeID]
			end
			

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
