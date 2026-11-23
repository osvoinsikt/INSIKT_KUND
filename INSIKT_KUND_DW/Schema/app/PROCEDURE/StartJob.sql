SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [app].[StartJob]
(
	@JobName sysname
	
	,@InitialWaitForJob int = 0
		--  0  = Starta inte jobbet om det redan körs
		--  1  = Vänta på att jobbet ska gå klart innan vi startar det
		--  -1 = Felmeddelande om jobbet redan körs.
	,@WaitTime datetime = '00:00:01' -- Tid mellan statuskontroller i de fall @InitialWaitForJob = 1
	,@TimeOut int = 600 -- 10 minuter = 600 sekunder
)
as
set nocount on

declare 
	@Status int
	,@StartWaitTime datetime
	,@StartJob bit

set @StartJob = 0

if ( select enabled from msdb.dbo.sysjobs_view o where o.name = @JobName ) = 0
	begin
		raiserror ('Jobbet %s kunde inte startas på grund av att det är avaktiverat.', 16, 10, @JobName)
		return -1;
	end

exec app.GetJobStatus @JobName, @Status out
if @Status in (2,4)
	begin
		if isnull(@InitialWaitForJob, 0) = -1
		begin
			--
			-- Rapportera fel
			--
			raiserror ('Jobbet %s kunde inte startas på grund av att det redan körs', 16,10, @JobName)
			return -1;
		end
		else if isnull(@InitialWaitForJob, 0) = 1
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

				set @StartJob = 1
			end
	end
else
	begin
		set @StartJob = 1
	end


--
-- Starta jobbet
--
if @StartJob = 1
	begin
		declare @StarRes int
		exec @StarRes = msdb.dbo.sp_start_job @JobName
		if @StarRes <> 0
			begin
				raiserror ('Kunde av okänd anledning inte starta jobbet %s.', 16,10, @JobName)
				return -1;
			end
	end
GO
