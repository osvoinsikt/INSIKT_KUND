SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Tells INSIKTService to run a scorecard KPI Integration.
*/
create procedure [dbo].[Support_RunScorecardKPIIntegration]
	-- Set this to sync a specific KPI
	@kpiKey nvarchar(15) = null,
	@runInput bit = 0,
	@runOutput bit = 0
as
begin
	if @runInput = @runOutput
	begin
		raiserror ('Only one of the parameters @runInput or @runOutput should be set when running a KPI Integration job.', 16, 10)
		return
	end

	declare @runInputString nvarchar(10) = iif(@runInput = 1, 'true', 'false')
	declare @runOutputString nvarchar(10) = iif(@runOutput = 1, 'true', 'false')
	declare @kpiKeyString nvarchar(20) = isnull('"' + @kpiKey + '"', 'null')

	declare @json varchar(max) = '
		{
			"KpiKey":' + @kpiKeyString + ',
			"RunInputIntegration":' + @runInputString + ',
			"RunOutputIntegration":' + @runOutputString + ',
			"IsFullReload":true
		}'

	insert into ServiceJob(ServiceJobTypeID, Body, CreatedBy, CreatedDate, NotifyUserTypeID)
	values (7, @json, -1, getutcdate(), 1)
end
GO
