SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Author:		TRIMMA Affärsutveckling AB
-- Description:	Procedur för att ladda diverse basdata
-- ==========================================================================================
-- LOG:
--	2013-03-26, TRIMMA	Standardimplementation
-- ==========================================================================================
CREATE procedure [dbo].[ETL_Base]
(
	@Type nvarchar(4000) = null
	,@ParamList nvarchar(4000) = null	
	,@ParentEventID int = null
)
as

-- select * from dw.dim_Time t order by 1 desc
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
			,@EventTitle = 'ETL Base'
			,@Description = ''
			
			

		--------------------------------------------------------------------------
		-- Ladda tidsdimension
		--------------------------------------------------------------------------		
		declare 
			@loadFrom datetime
			,@loadTom datetime
			,@logMessage nvarchar(1000)
		select
			--
			-- From = Backa två år från dagens datum 
			--
			@loadFrom = floor(cast(dateadd(year, -2, getdate()) as float))
			
			--
			-- Tom = Två år framåt
			--
			,@loadTom = floor(cast(dateadd(year, 5, getdate()) as float))
		
		--
		-- Ladda tabellen dw.dim_Time
		--	
		exec dbo.ETL_Base_DimTime
			@startdate = @loadFrom		-- Se till att samtliga datum inom intervallet @loadFrom och @loadTom finns med i tidsdimensionen
			,@stopdate = @loadTom
			,@lang = 'sv'				-- Möjliga val är sv för svenska eller en för engelska
			,@addNotSet = 1				-- Anger om datum 1900-01-01 ska skapas (med namnet datum ej angivet)
			,@ParentEventID = @EventIDStack
			
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
end CATCH

GO
