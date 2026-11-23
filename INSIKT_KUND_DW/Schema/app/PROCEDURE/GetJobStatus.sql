SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================= 
--  0 = Failed 
--  1 = Succeeded 
--  2 = Retry 
--  3 = Canceled 
--  4 = In progress 
--  5 = Disabled 
--  6 = Idle
-- ============================================= 
CREATE procedure [app].[GetJobStatus]
(
	@JobName sysname 
	,@Status int out
) as
begin
	declare @res table 
	(
		[session_id] [int] NOT NULL,
		[job_id] [uniqueidentifier] NOT NULL,
		[job_name] [sysname] NOT NULL,
		[run_requested_date] [datetime] NULL,
		[run_requested_source] [sysname] NULL,
		[queued_date] [datetime] NULL,
		[start_execution_date] [datetime] NULL,
		[last_executed_step_id] [int] NULL,
		[last_executed_step_date] [datetime] NULL,
		[stop_execution_date] [datetime] NULL,
		[next_scheduled_run_date] [datetime] NULL,
		[job_history_id] [int] NULL,
		[message] [nvarchar](4000) NULL,
		[run_status] [int] NULL,
		[operator_id_emailed] [int] NULL,
		[operator_id_netsent] [int] NULL,
		[operator_id_paged] [int] NULL
	)
	insert into @res
	exec msdb.dbo.sp_help_jobactivity @job_name = @JobName
	select
		@Status = 
			case
				when r.run_requested_date is null then 6				
				when r.stop_execution_date is null then isnull(r.run_status, 4)
				else isnull(r.run_status, 6)
			end
	from
		@res r			
			
end
GO
