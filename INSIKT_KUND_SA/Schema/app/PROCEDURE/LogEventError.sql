SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [app].[LogEventError]
(
	@EventIDStack varbinary(max) = null output
	,@LogEventStop bit = 1
	
	,@ErrorMessage nvarchar(4000) = null
	,@ErrorNumber int = null
	,@ErrorSeverity int = null
	,@ErrorState int = null
	,@ErrorProcedure nvarchar(128) = null
	,@ErrorLine int = null
	
	,@ETLID int = null
	,@EventLogID int	 = null
	,@EventObject sysname = null
	,@EventTitle nvarchar(255) = null
		   
	,@EventDescription nvarchar(max) = null	
	,@EventStop datetime = null
	,@EventUser nvarchar(255) = null		
	
	
)
as
set nocount on
if @ErrorMessage is null set @ErrorMessage = error_message()
if @ErrorNumber is null set @ErrorNumber = error_number()
if @ErrorSeverity is null set @ErrorSeverity = error_severity()
if @ErrorState is null set @ErrorState = error_state()
if @ErrorProcedure is null set @ErrorProcedure = error_procedure()
if @ErrorLine is null set @ErrorLine = error_line()

if @EventUser is null set @EventUser = suser_sname()
if @EventUser is null set @EventUser = convert(sysname, current_user)
if @EventStop is null set @EventStop = getdate()

if @EventLogID is null and @EventIDStack is not null
	set @EventLogID = CAST(@EventIDStack as int)

if @EventLogID is null
	begin
		select
			@EventLogID = max(ID)
		from
			app.EventLog
		where
			EventObject = @EventObject
			and (@EventTitle is null or @EventTitle = EventTitle)
			and (@ETLID is null or @ETLID = ETLID)
			and EventStop is null
	end

if @EventLogID is not null and @ETLID is null
	select
		@ETLID = ETLID
	from
		app.EventLog
	where
		ID = @EventLogID
		
	
begin try
	exec app.LogError 
		 @ErrorMessage = @ErrorMessage
		,@ErrorNumber = @ErrorNumber
		,@ErrorSeverity = @ErrorSeverity
		,@ErrorState = @ErrorState
		,@ErrorProcedure = @ErrorProcedure
		,@ErrorLine = @ErrorLine
		,@ErrorUser = @EventUser
		,@EventLogID = @EventLogID
		,@ETLID = @ETLID

	if @EventLogID is not null and @LogEventStop = 1		
		begin
			exec app.LogEventStop
				 @EventLogID = @EventLogID
				,@Description = @EventDescription
				,@EventStop = @EventStop
				,@EventUser = @EventUser
				,@EventIDStack = @EventIDStack out
		end
		
		
	return;
end try
begin catch
	print 'An error occurred in stored procedure ' + app.GetObjectFullName(@@procid) --object_name(@@procid);
	execute app.PrintError
	return -1;
end catch




GO
