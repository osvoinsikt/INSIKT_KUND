SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[IncUpdate_CreateOrUpdate_Job] 
(	
	@AgentJobName nvarchar(1024) = null
	,@Description nvarchar(4000) = null
	,@WaitTime varchar(11) = null	
	,@JobOwner nvarchar(1014) = null
	,@JobID int = null output
	,@Debug bit = 0
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
			,@EventTitle = 'Skapa SQL Server Agent Proxy for IncUpdate Job'
			,@Description = null

		declare 
			@DwDatabase nvarchar(1024) = DB_NAME()
			,@DynSQL nvarchar(max)
			,@DefaultWaitTime varchar(11) = '00:00:02'
			--,@OldAgentJobName nvarchar(1024)
		if @JobID is null 
			select @JobID = JobID from [app].IncUpdate_Job where AgentJobName = @AgentJobName
			

		if @TranCount = 0 begin tran
		if @JobID is not null
			begin
				--
				-- Jobbet finns redan, hämta/uppdatera dess parametrar
				--
				
				select
					@Description = isnull(@Description, j.Description)
					,@WaitTime = isnull(@WaitTime, j.WaitTime)
					,@AgentJobName = isnull(@AgentJobName, j.AgentJobName)
					--,@OldAgentJobName = j.AgentJobName
					,@JobOwner = 
						isnull
						(
							@JobOwner
							,
							(
								select top 1
									l.name
								from
									 msdb.dbo.sysjobs_view agentJobs
										inner join msdb.sys.syslogins l on
											l.sid = agentJobs.owner_sid
								where
									agentJobs.name = ISNULL(@AgentJobName, j.AgentJobName)
							)
						)
				from 
					[app].IncUpdate_Job j
					
				where
					j.JobID = @JobID

				if @@ROWCOUNT = 0
					raiserror('No job with JobID = %i exists in table [app].IncUpdate_Job.', 16, 10, @JobID)

				--if @OldAgentJobName = @AgentJobName set @OldAgentJobName = null
				if @Debug = 0
					update [app].IncUpdate_Job set
						AgentJobName = @AgentJobName
						,Description = @Description
						,WaitTime = isnull(@WaitTime,@DefaultWaitTime)
					where
						JobID = @JobID
			end
		else
			begin
				--
				-- Skapa ett helt nytt jobb
				--
				select @JobID = isnull(max(JobID)+1, 1) from [app].IncUpdate_Job
				if @Debug = 0
					begin
						insert into [app].IncUpdate_Job
						(
							JobID
							,AgentJobName
							,Description
							,WaitTime
							,Status
						)
						select
							JobID = @JobID
							,AgentJobName = @AgentJobName
							,Description = @Description
							,WaitTime = isnull(@WaitTime, @DefaultWaitTime)
							,Status  = 'Stopped'
					end
				
				
			end

		


		if @JobOwner is null and 
			exists
			(
				select
					l.name, r.name
				from
					msdb.sys.database_principals l
						inner join msdb.sys.database_role_members lrm on
							lrm.member_principal_id = l.principal_id
						inner join msdb.sys.database_principals r on
							r.principal_id = lrm.role_principal_id
							and r.name like 'SQLAgent%'
				where
					l.name = 'INSIKT_USER'
					and l.type = 'S'
			)
			set @JobOwner = N'INSIKT_USER'
		if @JobOwner is null
			set @JobOwner = SUSER_NAME()

	
	


		select
			@DynSQL = N'
/****** Object:  Job [' + @AgentJobName + N']    Script Date: 2022-03-03 11:35:56 ******/

DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 2022-03-03 11:35:56 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N''[Uncategorized (Local)]'' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N''[Uncategorized (Local)]''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N''' + @AgentJobName + N''', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N''' + replace(isnull(@Description,''), '''', '''''') + ''', 
		@category_name=N''[Uncategorized (Local)]'', 
		@owner_login_name=N''' + @JobOwner + N''', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Sätt status Running]    Script Date: 2022-03-03 11:35:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Sätt status Running'', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N''TSQL'', 
		@command=N''update [app].IncUpdate_Job set 
	[Status] = ''''Running''''
	,LastStatusChangeBy = ''''SQL Agent''''
where
	JobID = ' + cast(@JobID as nvarchar(max)) + N''', 
		@database_name=N''' + @DwDatabase + N''', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Vänta på data]    Script Date: 2022-03-03 11:35:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Vänta på data'', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=4, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N''TSQL'', 
		@command=N''exec [app].[IncUpdate_WaitForEvent] @JobID = ' + cast(@JobID as nvarchar(max)) + N''', 
		@database_name=N''' + @DwDatabase + N''', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Processa data]    Script Date: 2022-03-03 11:35:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Processa data'', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=2, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N''TSQL'', 
		@command=N''exec [app].[IncUpdate_EventHandler] @JobID = ' + cast(@JobID as nvarchar(max)) + N''', 
		@database_name=N''' + @DwDatabase + N''', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Sätt status Stopped]    Script Date: 2022-03-03 11:35:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Sätt status Stopped'', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N''TSQL'', 
		@command=N''declare @Error bit =  (exists(select 1 from app.IncUpdate_Job where JobID = ' + cast(@JobID as nvarchar(max)) + N' and Status = ''''Error''''), 1, 0)
update [app].[IncUpdate_Job] set [Status] = ''''Stopped'''' where JobID = ' + cast(@JobID as nvarchar(max)) + N'
if @Error = 1 raiserror(''''Error running job, see app.ErrorLog for more info.'''', 16, 10)'', 
		@database_name=N''' + @DwDatabase + N''', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

GOTO EndSave
QuitWithRollback:
	raiserror(''Unable to create job'', 16, 10);
EndSave:
		'

		print '--'
		print '-- Creating SQL Server Agent Job: "' + @AgentJobName  + '" with owner "' + @JobOwner + '"'
		print '--'
		if @Debug = 0
			begin				
				if exists(select * from msdb.dbo.sysjobs_view where name = @AgentJobName)
					begin
						print '* Remove existing job...'
						exec msdb.dbo.sp_delete_job @job_name = @AgentJobName
					end

				--if exists(select * from msdb.dbo.sysjobs_view where name = @OldAgentJobName)
				--	begin
				--		print '* Remove existing job...'
				--		exec msdb.dbo.sp_delete_job @job_name = @OldAgentJobName
				--	end
				print '* Create job...'
				print ''
				exec (@DynSQL)				
				print ''
				print 'Done!'
			end
		else
			begin
				if exists(select * from msdb.dbo.sysjobs_view where name = @AgentJobName)
					begin
						
						print 'exec msdb.dbo.sp_delete_job @job_name = ''' + @AgentJobName + ''''
					end

				--if exists(select * from msdb.dbo.sysjobs_view where name = @OldAgentJobName)
				--	begin
						
				--		print 'exec msdb.dbo.sp_delete_job @job_name = ''' + @OldAgentJobName + ''''
				--	end
				exec app.PrintMax @DynSQL
			end
	

		if @TranCount = 0 commit tran
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

return @JobID
GO
