SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- ==========================================================================================
create procedure [dbo].[ETL_InitVersion_Projekt_Fact_Projekt_Planning]
(
	@Type nvarchar(4000) = null
	,@ParamList nvarchar(4000) = null	
	,@ParentEventID int = null
	,@FCVersionID int
	,@FCProjectID int
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
			,@EventTitle = 'ETL InitVersion Projekt Fact Projekt Planning'
			,@Description = ''

    declare @RowTypeID int = 2002
	declare @DefaultRowTypeID int = @RowTypeID
    --Hämta ut föregående kalkylversion och i det här fallet PrevFCVersionID
	declare @PrevFCVersionID int = 
	(
		select 
			[PrevFCVersionID] = fcpv.PrevFCVersionID
		from insikt.FCProject_Versions fcpv
		where 
			FCProjectID = @FCProjectID
	)	

	select
		[FCProjectID] = f.FCProjectID
		,[FCVersionID] = @FCVersionID
		,[KontoID] = f.KontoID
		,[Kalkyl] = f.Kalkyl
		,[FgKalkyl] = f.Kalkyl
		,[AuditUser] = @ProcName
		,[AuditTime] = GETUTCDATE()
		,[ExistsInWriteTable] = 0
		,[IncUpdate] = 1
		,[RowTypeID] = @RowTypeID
	into #Kalkyl
	from dw.fact_Projekt_Planning_Sum f
	where
		f.FCVersionID = @PrevFCVersionID
		and f.FCProjectID = @FCProjectID
		and abs(f.Kalkyl) > 0.0001

    -- Defaultvärde på RowTypeID
    exec sys.sp_set_session_context
		@key = N'DEF:[dw].[fact_Projekt_Planning_Sum].[RowTypeID]',
		@value = @DefaultRowTypeID;

	exec [app].[SyncTable]
		@SourceTable = '#Kalkyl'
		,@TargetTable = '[dw].[fact_Projekt_Planning_Sum]'
		,@JoinColumns = 'FCProjectID, FCVersionID, KontoID'
		,@DeleteMode = 1
		,@TargetFilter = 
			'exists (
				select
					1
				from #Kalkyl src
				where
					src.[FCProjectID] = [dw].[fact_Projekt_Planning_Sum].[FCProjectID]
					and src.[FCVersionID] = [dw].[fact_Projekt_Planning_Sum].[FCVersionID]
				)'

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

GO
