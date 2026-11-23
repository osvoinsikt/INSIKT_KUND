SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Author:		TRIMMA Affärsutveckling AB
-- Description:	Procedur för att ladda diverse basdata
-- ==========================================================================================
-- LOG:
--	2024-03-20, TRIMMA	Standardimplementation
-- ==========================================================================================
create procedure [dbo].[ETL_Maintenance]
(
	@Type nvarchar(4000) = null
	,@ParamList nvarchar(4000) = null	
	,@ParentEventID int = null
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
			,@EventTitle = 'ETL Maintenance'
			,@Description = ''
			
			

		--------------------------------------------------------------------------
		-- Rensa loggar
		--------------------------------------------------------------------------		
		exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
			,@EventTitle = 'Remove old log posts'
			,@Description = 'DW'

			exec app.LogMaintenance
				@MonthsInLog = 24 -- Spara 2 år log i logtabeller, radera allt äldre än så.	
		
		exec app.LogEventStop @EventIDStack = @EventIDStack out

		/*
		exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
			,@EventTitle = 'Remove old log posts'
			,@Description = 'SA'

			exec INSIKT_SA.app.LogMaintenance
				@MonthsInLog = 24 -- Spara 2 år log i logtabeller, radera allt äldre än så.

		
		
		exec app.LogEventStop @EventIDStack = @EventIDStack out		
		*/
		--------------------------------------------------------------------------

		
		
		
		
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
