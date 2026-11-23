SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [app].[IncUpdate_IsJobRunning]
(
	@IsRunning bit out
	,@JobId varchar(512) = null
) as
begin
	set @IsRunning = 1


	declare @JobsToCheck table
	(
		JobID int not null primary key
	)
	if @JobId is null
		insert into @JobsToCheck
		select JobID from [app].[IncUpdate_Job]
	else
		insert into @JobsToCheck
		select try_cast(Item as int) from app.Split(@JobID, ',')
		where try_cast(Item as int) is not null


	declare 
		@IterateJobID int
		,@AgentJobName nvarchar(1024)
		,@JobStatus int

	select @IterateJobID = min(JobID) from @JobsToCheck
	while @IterateJobID is not null and @IsRunning = 1
		begin
			select
				@AgentJobName = j.AgentJobName
			from
				[app].[IncUpdate_Job] j
			where
				j.JobID = @IterateJobID

			exec app.GetJobStatus @AgentJobName, @JobStatus out

			if @JobStatus is null or @JobStatus not in (2,4)
				set @IsRunning = 0

			select @IterateJobID = min(JobID) from @JobsToCheck where JobID > @IterateJobID
		end
end
GO
