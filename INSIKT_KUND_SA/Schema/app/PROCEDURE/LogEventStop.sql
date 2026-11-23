SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [app].[LogEventStop]
(
	@EventIDStack varbinary(max) = null output
	,@ETLID int = null
	,@EventLogID int = null
	,@EventObject nvarchar(255) = null
	,@EventTitle nvarchar(255) = null
	,@Description nvarchar(max) = null
	,@EventStop datetime = null
	,@EventUser nvarchar(255) = null		
	
)
as

if @EventUser is null set @EventUser = suser_sname()
if @EventUser is null set @EventUser = convert(sysname, current_user)
if @EventStop is null set @EventStop = getdate()

if @EventLogID is not null and @EventIDStack is not null
	begin
		declare @TmpEventLogID int
		exec app.StackPopInt @TmpEventLogID out, @EventIDStack out
		
		if @TmpEventLogID <> @EventLogID
			exec app.LogError
				@ErrorMessage ='Event ID from @EventLogID parameter differs from the one popped from @EventIDStack.'
				,@ErrorProcedure = 'app.LogEventStop'
				,@EventLogID = @EventLogID
	end

if @EventLogID is null and @EventIDStack is not null
	begin
		exec app.StackPopInt @EventLogID out, @EventIDStack out
	end


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

update app.EventLog set
	 [Description] = coalesce(@Description, [Description])
	,EventUser = @EventUser
	,EventStop = @EventStop
where
	ID = @EventLogID



if @@ROWCOUNT = 0
	begin	
		set @Description = coalesce(@Description, '')
		raiserror('Unable to log event stop because ID: %d does not exist in table app.EventLog. Description for event stop: %s', 0, 10, @EventLogID, @Description)
	end




GO
