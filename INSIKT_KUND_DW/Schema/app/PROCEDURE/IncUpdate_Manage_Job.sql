SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[IncUpdate_Manage_Job]
(
    --
    -- Action:
    --  Start   Startar jobbet om det inte redan körs (från stillastående eller paused status)
    --  Stop    Stoppar jobbet på ett snyggt sätt och väntar till dess att jobbet gått klart.
    --  Pause   Pausar jobbet och väntar tills det att jobbet inge längre gör något förutom att startas igen.
    --
    @Action varchar(50)
    ,@JobID int = null
    ,@AuditUser nvarchar(512) = null
    ,@ParentEventID int = null
)
as
  
set nocount on
  
-- Standardvariabler
  
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount
  
declare
    @WaitTime datetime = '00:00:01' -- Tid mellan statuskontroller i de fall @InitialWaitForJob = 1
    ,@TimeOut int = 600 -- 10 minuter = 600 sekunder
  
declare
    @Status int
    ,@StartWaitTime datetime
  
begin try
--------------------------------------------------------------------------
-- Start
--------------------------------------------------------------------------
    declare
        @EventTitle nvarchar(4000) = 'IncUpdate_Manage_Job: '
        ,@AgentJobName nvarchar(4000)
  
    if @JobID is null
        begin
            select
                @JobID = JobID
                ,@AgentJobName = AgentJobName
            from
                [app].[IncUpdate_Job]
  
            if @@ROWCOUNT > 1
                select
                    @JobID = -1
                    ,@AgentJobName = 'Multiple'
        end
    else
        select
            @JobID = JobID
            ,@AgentJobName = AgentJobName
        from
            [app].[IncUpdate_Job]
        where
            JobID = @JobID
  
    set @EventTitle = @EventTitle + ISNULL(@AgentJobName, 'Missing')
  
    exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
        ,@EventTitle = @EventTitle
        ,@Description = @Action
  
    if @JobID is null
        raiserror('No IncUpdate Job found.', 16, 10)
  
    if @JobID = -1
        begin
            select @JobID = MIN(JobID) from [app].[IncUpdate_Job]
            while (@JobID is not null)
                begin
                    exec [app].[IncUpdate_Manage_Job]
                        @Action = @Action
                        ,@JobID = @JobID
                        ,@AuditUser = @AuditUser
                        ,@ParentEventID = @EventIDStack
  
                    select @JobID = MIN(JobID) from [app].[IncUpdate_Job] where JobID > @JobID
                end
        end
    else
        begin
  
            if @AuditUser is null
                set @AuditUser = SUSER_NAME()
  
            --
            -- Hämta status på agentjobbet.
            --
            exec app.GetJobStatus @AgentJobName, @Status out
            if @Action = 'Start'
            begin
        -----------------------------
        -- Starting
        --
                if @Status in (2,4)
                begin
                    --
                    -- Jobbet körs
                    --
                    if exists(select 1 from [app].IncUpdate_Job where Status = 'Paused' and JobID = @JobID)
                    begin
                        --
                        -- Jobbet körs men är pausat
                        --
                        update [app].IncUpdate_Job set
                            Status = 'Running'
                            ,LastStatusChangeBy = @AuditUser
                            where
                            Status in ('Paused')
                            and JobID = @JobID
                        --print 'Startar jobb - Från status PAUSED'
                    end
                    --
                    -- Kontrollera så att rätt status faktiskt har uppnåtts.
                    --
                    if not exists(select 1 from [app].IncUpdate_Job where Status = 'Running' and JobID = @JobID)
                    begin
                        raiserror ('Error: Lyckades inte sätta status ''Running'' på grund av okänd aktuell status eller pågående statusväxling %s.', 16,10, @AgentJobName)
                        return -1;
                    end
                end
                else
                begin
                    --
                    -- Agentjobbet verkar inte vara igång, vi startar det.
                    --
                    --print 'Startar jobb - Från stillastående'
                    update [app].IncUpdate_Job set
                        Status = 'Stopped'
                        ,LastStatusChangeBy = @AuditUser
                    where
                        JobID = @JobID
              
                    exec app.StartJob
                        @JobName = @AgentJobName
                        ,@InitialWaitForJob = -1
                        set @StartWaitTime = getdate()
                    while not exists(select 1 from [app].IncUpdate_Job where Status = 'Running' and JobID = @JobID) 
                    begin
                        if datediff(second,@StartWaitTime, getdate()) > @TimeOut and @TimeOut >= 0
                        begin
                            raiserror ('Timeout: Väntade på status ''Running'', %s.', 16,10, @AgentJobName)
                            return -1;
                        end
                        waitfor delay @WaitTime
                    end
                    update [app].IncUpdate_Job set
                        LastStatusChangeBy = @AuditUser
                    where
                        JobID = @JobID
                end
        --
        -- Starting
        -----------------------------
            end
            else if @Action = 'Stop'
            begin 
        -----------------------------
        -- Stopping
        --
                --print 'Stopping job'
                if @Status in (2,4)
                begin
                    --
                    -- Jobbet körs
                    --
                    update [app].IncUpdate_Job set
                        Status = 'Stopping'
                        ,LastStatusChangeBy = @AuditUser
                        where
                        Status not in('Stopping')
                        and JobID = @JobID
                    --
                    -- Vänta tills jobbet faktiskt har stannat
                    --
                    set @StartWaitTime = getdate()
                    while @Status in (2,4)  -- Så länge jobbet körs
                    begin
                        if datediff(second,@StartWaitTime, getdate()) > @TimeOut and @TimeOut >= 0
                        begin
                            raiserror ('Timeout: Väntade på status ''Stopped'', %s.', 16,10, @AgentJobName)
                            return -1;
                        end
                        waitfor delay @WaitTime
                        exec app.GetJobStatus @AgentJobName, @Status out  
                    end
                end
                else
                begin
                    --
                    -- Agentjobbet verkar inte vara igång??!
                    -- Sätt rätt status om det inte redan är det.
                    --
                    update [app].IncUpdate_Job set
                    Status = 'Stopped'
                    ,LastStatusChangeBy = @AuditUser
                    where
                    Status <> 'Stopped'
                    and JobID = @JobID
                end
        --
        -- Stopping
        -----------------------------
            end
            else if @Action = 'Pause'
            begin
        -----------------------------
        -- Pauseing
        --
                --print 'Pausing job'
                if @Status in (2,4)
                begin
                    --
                    -- Jobbet körs
                    --
                    update [app].IncUpdate_Job set
                        Status = 'Pausing'
                        ,LastStatusChangeBy = @AuditUser
                        where
                        Status not in('Paused','Pausing')
                        and JobID = @JobID
                    --
                    -- Vänta tills jobbet faktiskt har pausats
                    --
                    set @StartWaitTime = getdate()
                    while @Status in (2,4)  -- Så länge jobbet körs
                    and (exists(select 1 from [app].IncUpdate_Job where Status = 'Pausing' and JobID = @JobID)) -- Och vi väntar på pause.
                    begin
                        if datediff(second,@StartWaitTime, getdate()) > @TimeOut and @TimeOut >= 0
                        begin
                            raiserror ('Timeout: Väntade på status ''Paused'', %s.', 16,10, @AgentJobName)
                            return -1;
                        end
                        waitfor delay @WaitTime
                        exec app.GetJobStatus @AgentJobName, @Status out  
                    end
                    --
                    -- Kontrollera så att rätt status faktiskt har uppnåtts.
                    --
                    if not exists(select 1 from [app].IncUpdate_Job where Status = 'Paused' and JobID = @JobID)
                    begin
                        raiserror ('Error: Lyckades inte sätta status ''Paused'', %s.', 16,10, @AgentJobName)
                        return -1;
                    end
                end
                else
                begin
                    --
                    -- Agentjobbet verkar inte vara igång??!
                    --
                    update [app].IncUpdate_Job set
                        Status = 'Stopped'
                        ,LastStatusChangeBy = @AuditUser
                        where
                        Status <> 'Stopped'
                        and JobID = @JobID
                end
        --
        -- Pauseing
        -----------------------------
                end
                else
                begin
                    raiserror ('Error: Okänd action ''%s'' för jobbet %s.', 16,10, @Action, @AgentJobName)
                    return -1;
                end
        end
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
