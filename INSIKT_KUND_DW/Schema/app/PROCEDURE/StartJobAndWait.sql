SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [app].[StartJobAndWait]
(
	@JobName sysname
	
	,@Status int = 0 output
	
	,@TimeOut int = 600 -- 10 minuter = 600 sekunder
	
	,@InitialWaitForJob bit = 0 -- Vänta på att jobbet ska gå klart innan vi startar det
	,@WaitTime datetime = '00:00:01' -- Tid mellan statuskontroller
)
as
set nocount on
if @InitialWaitForJob is null set @InitialWaitForJob = 0
if @WaitTime is null set @WaitTime = '00:00:01'
if @TimeOut is null set @TimeOut = -1

declare @StartWaitTime datetime


if ( select enabled from msdb.dbo.sysjobs_view o where o.name = @JobName ) = 0
	begin
		raiserror ('Jobbet %s kunde inte startas på grund av att det är avaktiverat.', 16, 10, @JobName)
		return -1;
	end

exec app.GetJobStatus @JobName, @Status out
if @Status in (2,4)
	begin
		--
		-- Jobbet körs redan
		--
		if @InitialWaitForJob = 0
			begin
				--
				-- Rapportera fel
				--
				raiserror ('Jobbet %s kunde inte startas på grund av att det redan körs', 16,10, @JobName)
				return -1;
			end
		else
			begin
				--
				-- Vänta på jobbet att gå klart.
				--
				set @StartWaitTime = getdate()
				while @Status in (2,4)								
					begin
						if datediff(second,@StartWaitTime, getdate()) > @TimeOut and @TimeOut >= 0
							begin
								raiserror ('Timeout: Initial väntan på jobbet %s.', 16,10, @JobName)
								return -1;
							end
							
						waitfor delay @WaitTime
						exec app.GetJobStatus @JobName, @Status out
					end
			end
	end


--
-- Starta jobbet
--
declare @StarRes int
exec @StarRes = msdb.dbo.sp_start_job @JobName
if @StarRes <> 0
	begin
		raiserror ('Kunde av okänd anledning inte starta jobbet %s.', 16,10, @JobName)
		return -1;
	end
	
	
set @Status = 4 -- Fejka körande status för att gå in i loopen
set @StartWaitTime = getdate()
while @Status in (2,4)								
	begin		
		if datediff(second,@StartWaitTime, getdate()) > @TimeOut and @TimeOut >= 0
			begin
				raiserror ('Timeout: Väntan på jobbet %s.', 16,10, @JobName)
				return -1;
			end
			
		waitfor delay @WaitTime
		exec app.GetJobStatus @JobName, @Status out
	end 

return @Status
GO
