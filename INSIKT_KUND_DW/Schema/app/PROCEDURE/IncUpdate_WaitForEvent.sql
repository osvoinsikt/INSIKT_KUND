SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[IncUpdate_WaitForEvent]
(
    @JobID int
)
as
declare
    @CurrentJobStatus varchar(50)
    ,@WaitTime varchar(11)
select
    @CurrentJobStatus = [Status]
    ,@WaitTime = WaitTime
from
    [app].IncUpdate_Job
where
    JobID = @JobID
  
if @@ROWCOUNT = 0
    raiserror('No job with JobID %i found.', 16, 10, @JobID)
  
if @CurrentJobStatus = 'Pausing'
    begin
        set @CurrentJobStatus = 'Paused'
        update [app].IncUpdate_Job set Status = @CurrentJobStatus where JobID = @JobID
    end
  
if @CurrentJobStatus = 'Stopping'
    begin
        raiserror('Stopping job', 16, 10)
        return
    end
  
declare
    @CheckForEventDataQuery nvarchar(max) 
    ,@CheckForEventDataParams nvarchar(max) = '@WorkToBeDone int output'
    ,@WorkToBeDone int = 0
  
select
    @CheckForEventDataQuery =
	ISNULL
	(
    N'select @WorkToBeDone =
        iif
        ('
         +
        (
        select N'
            '
            + iif(row_number() over (order by tq.EventID) > 1, N'or ', N'')
            + 'exists(' + tq.TriggerQuery + N')'
        from
            [app].IncUpdate_EventConfiguration_TriggerQueryView tq
                inner join [app].IncUpdate_EventConfiguration e on
                    e.EventID = tq.EventID
        where
            tq.TriggerQuery <> ''
            and e.JobID = @JobID
			and e.IsDisabled = 0
        order by tq.EventID
        for xml path, type
        ).value(N'.[1]', N'nvarchar(max)')
        + N'
            ,1
            ,0
        )
	'
	,
	'')
	+
    isnull
	(
		 (
        select N'
if @WorkToBeDone = 0 exec @WorkToBeDone = ' + tq.TriggerProcedure 
           
        from
            [app].IncUpdate_EventConfiguration_TriggerQueryView tq
                inner join [app].IncUpdate_EventConfiguration e on
                    e.EventID = tq.EventID
        where
            tq.TriggerProcedure <> ''
            and e.JobID = @JobID
			and e.IsDisabled = 0
        order by tq.EventID
        for xml path, type
        ).value(N'.[1]', N'nvarchar(max)')
		,''
	)

declare @StopJob bit = 0
       
begin try 	
	if isnull(@CheckForEventDataQuery , N'') = N''
		raiserror('No IncUpdate Events are configured in IncUpdate_EventConfiguration for JobID = %i', 16,10, @JobID)
 
	exec sp_executesql
		@stmt = @CheckForEventDataQuery
		,@params = @CheckForEventDataParams
		,@WorkToBeDone = @WorkToBeDone output
  
  
	while @WorkToBeDone = 0 or @CurrentJobStatus = 'Paused'
		begin
			waitfor delay @WaitTime
			select @CurrentJobStatus = [Status] from [app].IncUpdate_Job where JobID = @JobID
			if @CurrentJobStatus = 'Stopping'
				begin
					set @StopJob = 1
					break				
				end
			else if @CurrentJobStatus = 'Pausing'
				begin
					set @CurrentJobStatus = 'Paused'
					update [app].IncUpdate_Job set Status = @CurrentJobStatus where JobID = @JobID
				end
  
			exec sp_executesql
				@stmt = @CheckForEventDataQuery
				,@params = @CheckForEventDataParams
				,@WorkToBeDone = @WorkToBeDone output
		end
end try
begin catch	
	
	declare @Error nvarchar(max)
	select @Error = formatmessage('Error looking for event data for JobID %i: Error: "%s" while running sql: "%s"'
		,@JobID		
		,app.GetErrorMessage()
		,@CheckForEventDataQuery
		);
	exec app.LogError @Error

	update [app].IncUpdate_Job set Status = 'Error' where JobID = @JobID

	raiserror (@Error, 16, 10)
end catch

if @StopJob = 1 raiserror ('Stopping job', 11, 10)
GO
