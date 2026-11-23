SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [insikt].[OnCubeUpdated_WaitFor_IncUpdate]
( 
    @EventID varchar(4000)
    ,@FCTypeID int
)
as
--
-- Standardvariabler
--
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount

set transaction isolation level read uncommitted;
  
declare
    @Type nvarchar(4000) = null
    ,@ParamList nvarchar(4000) = null 
    ,@ParentEventID int = null
  
begin try
	declare
		@eventTitle nvarchar(max)
		,@description nvarchar(max)
	select
		@eventTitle = 'OnCubeUpdated_IncUpdate_Planning FCTypeID = ' 
			+ isnull(cast(@FCTypeID as varchar(12)), 'NULL')
		,@description = 'Wait for EventID: ' + isnull(@EventID, 'NULL')
  
	exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
			,@EventTitle = @eventTitle
			,@Description = @description

	create table #WaitForEvents
	(
		EventOrderID int not null primary key
		,EventID varchar(512)
	)
	insert into #WaitForEvents
	(
		EventOrderID
		,EventID
	)
	select
		EventOrderID = e.ListPos
		,EventID = e.Item
	from 
		app.Split(@EventID, ',') e

    --------------------------------------------------------------------------
    -- Start
    --------------------------------------------------------------------------
    declare
        @EventTriggerTypeID varchar(10)
        ,@EventName nvarchar(1024)
        ,@TriggerTable nvarchar(1024)
        ,@GetMaxQuery nvarchar(max)
        ,@GetMaxQyeryParam nvarchar(max)
      
  
        ,@WaitForEventQuery nvarchar(max)
        ,@WaitForEventQueryParam nvarchar(max)


	
	declare @EventIDInt int
	declare @EventOrderID int = 1
	while exists(select 1 from #WaitForEvents where EventOrderID = @EventOrderID)
		begin
			select @EventIDInt = try_cast(EventID as int) From #WaitForEvents where EventOrderID = @EventOrderID
			select
				@EventTriggerTypeID = null
				,@EventName = null
				,@TriggerTable = null
				,@GetMaxQuery = null
				,@GetMaxQyeryParam = null
				,@WaitForEventQuery = null
				,@WaitForEventQueryParam = null
		
			if @EventIDInt is null
				raiserror('@EventID has an invalid value of ''%s''. It should be a comma separated list of integers.', 16, 10, @EventID)
          
			

			select
				@EventTriggerTypeID = e.EventTriggerTypeID
				,@EventName = e.Name
				,@TriggerTable = e.TriggerTable
				,@GetMaxQuery = N'
					select
						@MaxIncUpdateID = MAX(ID)
					from
						(
							' + tq.TriggerQuery + '
						)tq(ID)'
				,@GetMaxQyeryParam = '@MaxIncUpdateID int output'
          
				,@WaitForEventQuery = '
					while
					(
						exists
						(
							select top 1
								DoWait = 1
							from
								(
									' + tq.TriggerQuery + '
								)tq(ID)
							where
								ID <= @MaxIncUpdateID
						)
						and
						(
							getutcdate() < @TimeoutAt
						)
					)
					begin
						waitfor delay @CheckIntervalWaitTime              
					end'
  
				,@WaitForEventQueryParam = '@TimeoutAt datetime, @CheckIntervalWaitTime char(8), @MaxIncUpdateID bigint'
			from
				app.IncUpdate_EventConfiguration e
					inner join app.IncUpdate_EventConfiguration_TriggerQueryView tq on
						tq.EventID = e.EventID
			where
				e.EventID = @EventIDInt
				and e.IsDisabled = 0
  
          
			if @EventTriggerTypeID is null
				raiserror('EventID = %i is not correct configured in IncUpdate_EventConfiguration', 16, 10, @EventIDInt)
  
			else if @EventTriggerTypeID not in ('IncUpdate', 'RowsExists')
				raiserror('EventID = %i has a unsupported TriggerType %s for OnCubeUpdated_WaitFor_IncUpdate. Only IncUpdate and RowsExists are supported.', 16, 10, @EventIDInt, @EventTriggerTypeID)
			else
				if isnull(@GetMaxQuery, N'') = N''
					raiserror('EventID = %i has no trigger query. Verify support view: IncUpdate_EventConfiguration_TriggerQueryView ', 16, 10, @EventIDInt)
  
			declare @CheckIntervalWaitTime char(8) = '00:00:00.500'           
			declare @StartTime datetime = getutcdate()
			declare @TimeoutAt datetime = @StartTime + '00:00:20'
          
  
			declare @MaxIncUpdateID bigint
			--
			-- Hämta max ID för IncUpdate
			--
			exec sp_executesql
				@stmt = @GetMaxQuery
				,@params = @GetMaxQyeryParam
				,@MaxIncUpdateID = @MaxIncUpdateID output
  
			--
			-- Vänta tills det nyss senaste IncUpdate-id:t är hanterat.
			--
			exec sp_executesql
				@stmt = @WaitForEventQuery
				,@params = @WaitForEventQueryParam
				,@TimeoutAt = @TimeoutAt
				,@CheckIntervalWaitTime = @CheckIntervalWaitTime
				,@MaxIncUpdateID = @MaxIncUpdateID

		
			set @EventOrderID = @EventOrderID + 1
		end
          
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
      
  
    select
        Status = 99
        ,Message = isnull(error_message(), 'Error in ' + @ProcName)
  
end catch
GO
