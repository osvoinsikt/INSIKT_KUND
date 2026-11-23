SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [app].[HandleProcError]
(
	@EventIDStack varbinary(max) = null output
	,@ParentEventID int = null
	,@ProcName sysname = null
	
	
	,@ETLID int = null
	
)
as

--
-- Print error information just to be sure the error is not lost.
-- If the error is serious enough we will not be able to store error information into log table.
--
exec app.PrintError


declare @ErrorLogCount int
set @ErrorLogCount = 0



if @EventIDStack is null and @ProcName is null
	begin
		exec app.LogError			
		raiserror('Either @LogIDStack or @ProcName must have a value to be able to handle errors.', 16,10)
		return
	end
	
--
-- A transaction might be active but in that case it was not started by this procedure.						
--
declare @EventLogID int

if @EventIDStack is null
	begin
		select
			@EventLogID = max(ID)
		from
			app.EventLog
		where
			EventObject = @ProcName	
			and (@ETLID is null or @ETLID = ETLID)
			and EventStop is null
			
		while @EventLogID is not null
			begin
				exec LogEventError
					@ETLID = @ETLID
					,@EventLogID = @EventLogID					
					,@ErrorProcedure = @ProcName
					
				select
					@EventLogID = max(ID)
				from
					app.EventLog
				where
					EventObject = @ProcName	
					and (@ETLID is null or @ETLID = ETLID)
					and EventStop is null
					and ID < @EventLogID
				
				set @ErrorLogCount = @ErrorLogCount + 1
			end
	end
else
	begin
		if @ETLID is null
			select 
				@ETLID = ETLID
			from
				app.EventLog
			where
				ID = CAST(@EventIDStack as int)
		
		select
			@EventLogID = max(s.Value)	
			,@ETLID = isnull(@ETLID, max(e.ETLID))		
		from
			 app.StackListInt(@EventIDStack) s
				inner join app.EventLog e on
					e.ID = s.Value
		where			
			e.EventStop is null
			
		while @EventLogID is not null
			begin
				exec app.LogEventError
					@ETLID = @ETLID
					,@EventLogID = @EventLogID
					,@ErrorProcedure = @ProcName
					
				select
					@EventLogID = max(s.Value)
				from
					app.StackListInt(@EventIDStack) s
						inner join app.EventLog e on
							e.ID = s.Value
				where			
					e.EventStop is null
					and s.Value < @EventLogID
					
				set @ErrorLogCount = @ErrorLogCount + 1
			end
			
		set @EventIDStack = null
	end


if @ErrorLogCount = 0
	begin
		--
		-- No error is yet logged. Probobly due to poor logging and transactans in calling procedure.
		--
		if @ETLID is null and @ParentEventID is not null
			select @ETLID = ETLID from app.EventLog where ID = @ParentEventID
			
		exec app.LogError					
			@ETLID = @ETLID
	end




GO
