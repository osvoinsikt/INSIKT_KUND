SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[CustomInvoiceFetcher_CreateOrUpdate_Job]
(  
     @FetcherID nvarchar(50)
    ,@DatabaseName varchar(512) = null
    ,@QueueTable varchar(512) = null
    ,@ResultTable varchar(512) = null
    ,@CustomInvoiceFetcherCmd nvarchar(1024) = null
    ,@AgentProxyName varchar(512) = null
    ,@AgentJobName varchar(512) = null
    ,@AgentJobDescription nvarchar(4000) = null
    ,@AgentJobOwner varchar(512) = null
    ,@AgentTimeoutInSecounds int = null
    ,@CheckForResultInterval varchar(12) = null    
    ,@Debug bit = 0
    ,@ParentEventID int = null
)
as
if @DatabaseName like '[[]%]' set @DatabaseName = parsename(@DatabaseName, 1)
  
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
            ,@EventTitle = 'Create SQL Server Agent Job for CustomInvoiceFetcher'
            ,@Description = @FetcherID
        declare
            @DefaultAgentJobName varchar(512) =
                'INSIKT' +
                iif(db_name() like 'INSIKT[_]%_[_]DW', '_' + substring(db_name(), 8, len(db_name()) - 10), '') +
                ' - CustomInvoiceFetcher - ' + @FetcherID
            ,@DefaultAgentJobNameDescription nvarchar(4000) =  'Agent job for custom invoice fetcher ' + @FetcherID + '.\r\n'              
            ,@DefaultAgentJobOwner varchar(512) = null
            ,@DefaultAgentTimeoutInSecounds int = 120
            ,@DefaultCheckForResultInterval varchar(12) = '00:00:00:100'
            ,@DefaultAgentProxy varchar(512)
  
        select
            @DefaultAgentProxy = proxy.name
        from
            msdb.dbo.syssubsystems cmd
                inner join msdb.dbo.sysproxysubsystem cmd_proxy on
                    cmd_proxy.subsystem_id = cmd.subsystem_id
                inner join msdb.dbo.sysproxies proxy on
                    proxy.proxy_id = cmd_proxy.proxy_id
        where
            cmd.subsystem = 'CmdExec'
            and proxy.enabled = 1
            and
            (
                proxy.name like '%INSIKT%'
                and proxy.name like iif(db_name() like 'INSIKT[_]%_[_]DW', '%' + substring(db_name(), 8, len(db_name()) - 10) + '%', '%')
            )
        if @@ROWCOUNT > 1 set @DefaultAgentProxy = null
        if @DefaultAgentProxy is null
            begin
                select
                    @DefaultAgentProxy = proxy.name
                from
                    msdb.dbo.syssubsystems cmd
                        inner join msdb.dbo.sysproxysubsystem cmd_proxy on
                            cmd_proxy.subsystem_id = cmd.subsystem_id
                        inner join msdb.dbo.sysproxies proxy on
                            proxy.proxy_id = cmd_proxy.proxy_id
                where
                    cmd.subsystem = 'CmdExec'
                    and proxy.enabled = 1
                    and
                    (
                        proxy.name like '%INSIKT%'
                    )
                if @@ROWCOUNT > 1 set @DefaultAgentProxy = null
            end
  
        declare            
            @DynSQL nvarchar(max)      
            ,@OldAgentJobName varchar(512)
  
        if @TranCount = 0 begin tran
        if exists (select 1 from [app].[CustomInvoiceFetcherConfig] where [FetcherID] = @FetcherID)
            begin
                --
                -- CustomInvoiceFetcher finns redan, hämta/uppdatera dess parametrar
                --             
                select
                    @QueueTable = isnull(@QueueTable, j.QueueTable)
                    ,@ResultTable = isnull(@ResultTable, j.ResultTable)                
                    ,@AgentJobName = coalesce(@AgentJobName, j.AgentJobName, @DefaultAgentJobName)
                    ,@OldAgentJobName = j.AgentJobName
                    ,@AgentTimeoutInSecounds = coalesce(@AgentTimeoutInSecounds, j.AgentTimeoutInSecounds, @DefaultAgentTimeoutInSecounds)
                    ,@CheckForResultInterval = coalesce(@CheckForResultInterval, j.CheckForResultInterval, @DefaultCheckForResultInterval)
                    ,@DatabaseName = isnull(@DatabaseName, j.DatabaseName)                         
                from
                    [app].[CustomInvoiceFetcherConfig] j                       
                where
                    [FetcherID] = @FetcherID
  
                if @OldAgentJobName = @AgentJobName set @OldAgentJobName = null
                if @Debug = 0
                    update [app].[CustomInvoiceFetcherConfig] set
                        [AgentJobName] = @AgentJobName
                        ,[DatabaseName] = @DatabaseName
                        ,[QueueTable] = @QueueTable
                        ,[ResultTable] = @ResultTable
                        ,[AgentTimeoutInSecounds] = @AgentTimeoutInSecounds
                        ,[CheckForResultInterval] = @CheckForResultInterval
                    where
                        [FetcherID] = @FetcherID
            end
        else
            begin
                --
                -- En splitt ny CustomInvoiceFetcher
                --
                select             
                    @AgentJobName = isnull(@AgentJobName, @DefaultAgentJobName)
                    ,@AgentTimeoutInSecounds = isnull(@AgentTimeoutInSecounds, @DefaultAgentTimeoutInSecounds)
                    ,@CheckForResultInterval = isnull(@CheckForResultInterval, @DefaultCheckForResultInterval)
                    ,@AgentJobDescription = isnull(@AgentJobDescription, @DefaultAgentJobNameDescription)
 
  
                if @Debug = 0
                    begin
                        insert into [app].[CustomInvoiceFetcherConfig]
                        (
                            [FetcherID]
                            ,[AgentJobName]
                            ,[DatabaseName]
                            ,[QueueTable]
                            ,[ResultTable]
                            ,[AgentTimeoutInSecounds]
                            ,[CheckForResultInterval]
                        )
                        select
                            @FetcherID
                            ,@AgentJobName
                            ,@DatabaseName
                            ,@QueueTable
                            ,@ResultTable
                            ,@AgentTimeoutInSecounds
                            ,@CheckForResultInterval
                    end
            end
  
        select
            @AgentJobOwner =
                isnull
                (
                    @AgentJobOwner
                    ,
                    (
                        select top 1
                            l.name
                        from
                                msdb.dbo.sysjobs agentJobs
                                inner join msdb.sys.syslogins l on
                                    l.sid = agentJobs.owner_sid
                        where
                            agentJobs.name = @AgentJobName
                    )
                )
            ,@AgentJobDescription =
                coalesce
                (
                    @AgentJobDescription
                    ,
                    (
                        select top 1
                            description
                        from
                                msdb.dbo.sysjobs agentJobs
                        where
                            agentJobs.name = @AgentJobName
                    )
                    ,@DefaultAgentJobNameDescription
                )
            ,@AgentProxyName =
                coalesce
                (
                    @AgentProxyName                        
                    ,
                    (
                        select top 1
                            p.name
                        from
                                msdb.dbo.sysjobs agentJobs
                                inner join msdb.dbo.sysjobsteps s on
                                    s.job_id = agentJobs.job_id
                                inner join msdb.dbo.sysproxies p on
                                    p.proxy_id = s.proxy_id
                        where
                            agentJobs.name = @AgentJobName
                            and s.step_id = 2
                    )                          
                    ,
                    @DefaultAgentProxy
                )
            ,@CustomInvoiceFetcherCmd =
                coalesce
                (
                    @CustomInvoiceFetcherCmd                           
                    ,
                    (
                        select top 1
                            s.command
                        from                       
                            msdb.dbo.sysjobs agentJobs
                                inner join msdb.dbo.sysjobsteps s on
                                    s.job_id = agentJobs.job_id                            
                        where
                            agentJobs.name = @AgentJobName
                            and s.step_id = 2
                            and s.subsystem = 'CmdExec'
                    )                          
                    ,
                    @DefaultAgentProxy
                )
        if @AgentJobOwner is null and
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
            set @AgentJobOwner = N'INSIKT_USER'
        if @AgentJobOwner is null
            set @AgentJobOwner = SUSER_NAME()
  
declare
    @QueueTableFqn varchar(512) =
        isnull(quotename(@DatabaseName) + '.', '')
        + quotename(parsename(@QueueTable, 2)) + '.' + quotename(parsename(@QueueTable, 1))
    ,@ResultTableFqn varchar(512) =
        isnull(quotename(@DatabaseName) + '.', '')
        + quotename(parsename(@ResultTable, 2))
        + '.' + quotename(parsename(@ResultTable, 1))
 
  
if object_id(@QueueTableFqn) is null
    raiserror('Queue table %s does not exist.', 16 ,10, @QueueTableFqn)
if object_id(@ResultTableFqn) is null
    raiserror('Result table %s does not exist.', 16 ,10, @ResultTableFqn)
if @AgentProxyName is null
    raiserror('Warning: No proxy is set when running %s. It will probably fail.', 8, 1, @CustomInvoiceFetcherCmd)
if @CustomInvoiceFetcherCmd is null
    raiserror('No @CustomInvoiceFetcherCmd, cannot create agent job without it.', 16, 10)
  
        select
            @DynSQL = N'
/****** Object:  Job [' + cast(@AgentJobName as nvarchar(max)) + N']    Script Date: 2022-03-03 11:35:56 ******/
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 2022-03-03 11:35:56 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N''[Uncategorized (Local)]'' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N''[Uncategorized (Local)]''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END
DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N''' + cast(@AgentJobName as nvarchar(max)) + N''',
        @enabled=1,
        @notify_level_eventlog=2,
        @notify_level_email=0,
        @notify_level_netsend=0,
        @notify_level_page=0,
        @delete_level=0,
        @description=N''' + cast(replace(isnull(@AgentJobDescription,''), '''', '''''') as nvarchar(max)) + N''',
        @category_name=N''[Uncategorized (Local)]'',
        @owner_login_name=N''' + cast(@AgentJobOwner as nvarchar(max)) + N''', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Markera request som ska hanteras]    Script Date: 2023-11-23 15:33:07 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Markera request som ska hanteras'',
        @step_id=1,
        @cmdexec_success_code=0,
        @on_success_action=3,
        @on_success_step_id=0,
        @on_fail_action=2,
        @on_fail_step_id=0,
        @retry_attempts=0,
        @retry_interval=0,
        @os_run_priority=0, @subsystem=N''TSQL'',
        @command=N''update ' + cast(@QueueTable as nvarchar(max)) + N' set
    FetcherStatus = 1
where
    FetcherStatus = 0'',
        @database_name=N''' + cast(replace(parsename(@DatabaseName, 1), '''', '''''') as nvarchar(max)) + N''',
        @flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Invoice Fetcher.exe]    Script Date: 2023-11-23 15:33:07 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Invoice Fetcher.exe'',
        @step_id=2,
        @cmdexec_success_code=0,
        @on_success_action=3,
        @on_success_step_id=0,
        @on_fail_action=2,
        @on_fail_step_id=0,
        @retry_attempts=0,
        @retry_interval=0,
        @os_run_priority=0, @subsystem=N''CmdExec'',
        @command=N''' + cast(replace(@CustomInvoiceFetcherCmd, '''', '''''') as nvarchar(max)) + N''',
        @flags=0,
        @proxy_name=' + isnull('N''' + cast(replace(@AgentProxyName, '''', '''''') as nvarchar(max)) + N'''', 'null') + '
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Kontrollera om fler requests finns]    Script Date: 2023-11-23 15:33:07 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Kontrollera om fler requests finns'',
        @step_id=3,
        @cmdexec_success_code=0,
        @on_success_action=1,
        @on_success_step_id=0,
        @on_fail_action=4,
        @on_fail_step_id=1,
        @retry_attempts=0,
        @retry_interval=0,
        @os_run_priority=0, @subsystem=N''TSQL'',
        @command=N''--
-- Kontrollera om mer request kommit in medan vi hanterade föregående
-- Om så är fallet, rais error, för att signalera till Agentjobbet att hoppa till
-- steg 1.
-- Annars, avsluta jobbet med status success.
--
if exists
(
    select 1
    from
        ' + cast(@QueueTable as nvarchar(max)) + N'
    where
        FetcherStatus = 0
)
raiserror(''''Mer data finns att hantera, kör ett varv till.'''', 11, 1)'',
        @database_name=N''' + cast(replace(parsename(@DatabaseName, 1), '''', '''''') as nvarchar(max)) + N''',
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
        print '-- Creating SQL Server Agent Job: "' + @AgentJobName  + '" with owner "' + @AgentJobOwner + '"'
        print '--'
        if @Debug = 0
            begin              
                if exists(select * from msdb.dbo.sysjobs where name = @AgentJobName)
                    begin
                        print '* Remove existing job...'
                        exec msdb.dbo.sp_delete_job @job_name = @AgentJobName
                    end
                --if exists(select * from msdb.dbo.sysjobs where name = @OldAgentJobName)
                --  begin
                --      print '* Remove existing job...'
                --      exec msdb.dbo.sp_delete_job @job_name = @OldAgentJobName
                --  end
                print '* Create job...'
                print ''
                exec (@DynSQL)             
                print ''
                print 'Done!'
            end
        else
            begin
                if exists(select * from msdb.dbo.sysjobs where name = @AgentJobName)
                    begin
                        print 'exec msdb.dbo.sp_delete_job @job_name = ''' + @AgentJobName + ''''
                    end
                --if exists(select * from msdb.dbo.sysjobs where name = @OldAgentJobName)
                --  begin
                --      print 'exec msdb.dbo.sp_delete_job @job_name = ''' + @OldAgentJobName + ''''
                --  end
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
GO
