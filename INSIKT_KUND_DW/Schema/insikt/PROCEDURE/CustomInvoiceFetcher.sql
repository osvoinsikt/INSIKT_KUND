SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [insikt].[CustomInvoiceFetcher]
(
	@FetcherID varchar(50)
	,@FetcherParams nvarchar(max)
	
)
as

--
-- Standardvariabler
--
declare @ParentEventID int = null
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount

declare 
	@ClearQueueSql nvarchar(max)
	,@ClearQueueSqlParams nvarchar(max) = '@SPID int'
	

begin try
	--------------------------------------------------------------------------
	-- Start
	--------------------------------------------------------------------------
	exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
			,@EventTitle = 'Custom invoice fetcher'
			,@Description = @FetcherID


		declare 
			@AgentJobName varchar(512)
			,@AgentTimeoutInSecounds int
			,@CheckForResultInterval varchar(12)			
			,@QueueTable varchar(512)
			,@ResultTable varchar(512)
			

		select
			@AgentJobName = AgentJobName
			,@AgentTimeoutInSecounds = AgentTimeoutInSecounds
			,@CheckForResultInterval = CheckForResultInterval			
			,@QueueTable = isnull(quotename(DatabaseName) + '.', '') + quotename(parsename(QueueTable, 2)) + '.' + quotename(parsename(QueueTable, 1))
			,@ResultTable = isnull(quotename(DatabaseName) + '.', '') + quotename(parsename(ResultTable, 2)) + '.' + quotename(parsename(ResultTable, 1))
		from
			app.CustomInvoiceFetcherConfig
		where
			FetcherID = @FetcherID

		if @@ROWCOUNT = 0 
			raiserror('Custom invoice fetcher with FetcherID %s not found in app.CustomInvoiceFetcherConfig.', 16, 10, @FetcherID)


		
		select
			@ClearQueueSql = 
				'declare @SpidsToRemove table(SPID int not null primary key);' +
				'insert into @SpidsToRemove select @SPID union select SPID from	' + @QueueTable + ' where CreatedDate <= dateadd(day, 1, getutcdate());' +

				'delete From ' + @ResultTable + ' where SPID in (select SPID from @SpidsToRemove);' +
				'delete From ' + @QueueTable + ' where SPID in (select SPID from @SpidsToRemove);'
		

		-- Se till att vi rensar i kön för @SPID så att det inte finns några jobb som ligger kvar
		-- Vi gör en rensning efter jobbet är klart men detta är en extra kontroll.
		exec sp_executesql @ClearQueueSql, @ClearQueueSqlParams, 
			@SPID = @@SPID


		
		declare 
			@AddToQueueSql nvarchar(max) =

				'
					insert into ' + @QueueTable + '
					(
						SPID
						,FetcherParams
						,FetcherStatus
						,CreatedDate
					)
					values
					(
						@SPID
						,@FetcherParams
						,@FetcherStatus
						,getutcdate()
					)
				'
			,@AddToQueueSqlParams nvarchar(max) = '@SPID int, @FetcherParams nvarchar(max), @FetcherStatus int'


		-- Lägg till i kön för att att låta invoicefetchern hantera och hämta fakutran.
		exec sp_executesql @AddToQueueSql, @AddToQueueSqlParams, 
			@SPID = @@SPID
			,@FetcherParams = @FetcherParams
			,@FetcherStatus = 0

		-- Agentjobbet kommer att hantera att det kommer in nya värden under körning.
		-- Om vi skulle lägga till ett värde i kön precis mellan sista steget och agentjobbet stängs så finns det en risk att jobbet inte startas.
		-- Därför existerar det en kort delay här.
		waitfor delay '00:00:00:100' 

		

		-- Startar invoicefetcher agentjobbet
		exec app.StartJob
			@JobName = @AgentJobName
			,@InitialWaitForJob = 0 -- Om jobbet redan är igång, starta det inte, jobbet hanterar requestet ändå.

		
		declare 
			@WaitForResultSql nvarchar(max) =
				'
				set nocount on;
				declare 
					@TimeoutAt datetime = dateadd(SECOND, @AgentTimeoutInSecounds, getdate())
					,@JobStatus int	=  4			
				while exists(select 1 from ' + @QueueTable + ' where SPID = @SPID and FetcherStatus between 0 and 99) and @JobStatus in (4, 2)
					begin
						exec [app].[GetJobStatus]
							@JobName = @AgentJobName
							,@Status = @JobStatus out

						if @JobStatus = 0 -- Failed
							begin
								update ' + @QueueTable + ' set FetcherStatus = -100 where SPID = @SPID

								raiserror(''Error running invoice fetcher agent job: %s'', 16, 10, @AgentJobName)
							end
						waitfor delay @CheckForResultInterval;
						if getdate() > @TimeoutAt
							begin
								update ' + @QueueTable + ' set FetcherStatus = -10 where SPID = @SPID

								raiserror(''Timeout waiting for result from invoice fetcher agent job %s'', 16, 10, @AgentJobName)					
							end
					end
				'
			,@WaitForResultSqlParams nvarchar(max) = '@SPID int, @AgentJobName varchar(512), @AgentTimeoutInSecounds int, @CheckForResultInterval varchar(12)'

		
		-- Pollar efter resultat från invoicefetchern
		exec sp_executesql @WaitForResultSql, @WaitForResultSqlParams, 
			@SPID = @@SPID
			,@AgentJobName = @AgentJobName
			,@AgentTimeoutInSecounds = @AgentTimeoutInSecounds
			,@CheckForResultInterval = @CheckForResultInterval


		declare 
			@SelectResultSql nvarchar(max) =
				'
				declare @FetcherStatus int, @FetcherMessage nvarchar(max)
				select @FetcherStatus = FetcherStatus, @FetcherMessage = FetcherMessage from  ' + @QueueTable + ' where SPID = @SPID 
				if @FetcherStatus <> 100
					raiserror(''Invalid FetcherStatus for SPID: %i. FetcherStatus = %i, Message: %s'',16, 10, @SPID, @FetcherStatus, @FetcherMessage)

				select
					FileBlob
					,FileExtension
				from
					' + @ResultTable + '
				where
					SPID = @SPID
				'
			,@SelectResultSqlParams nvarchar(max) = '@SPID int'

		-- Selecta ut resultat sså vi skickar fakturan som en blob till INSIKT
		exec sp_executesql @SelectResultSql, @SelectResultSqlParams, 
			@SPID = @@SPID

		

		-- Se till att vi resnar kön för nuvarande @SPID
		exec sp_executesql @ClearQueueSql, @ClearQueueSqlParams, 
			@SPID = @@SPID

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

	if @ClearQueueSql is not null
		exec sp_executesql @ClearQueueSql, @ClearQueueSqlParams, 
			@SPID = @@SPID

	exec app.ReThrowError
end catch
GO
