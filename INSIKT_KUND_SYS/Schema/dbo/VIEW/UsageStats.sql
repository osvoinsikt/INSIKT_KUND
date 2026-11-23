SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UsageStats]
AS
SELECT sessionLog.Date, 
	sessionLog.UserCount,
	sessionLog.AverageTabCount,
	ISNULL(analysisReportUsage.OpenCount, 0) AS AnalysisReportsOpened,
	ISNULL(rsReportUsage.OpenCount, 0) AS ReportingServicesReportsOpened,
	ISNULL(created.NrCreatedProcesses, 0) AS NrCreatedProcesses, 
	ISNULL(finished.NrFinishedProcesses, 0) AS NrFinishedProcesses, 
	ISNULL(approved.NrApprovedProcesses, 0) AS NrApprovedProcesses 
FROM SessionLogSummary sessionLog
LEFT OUTER JOIN 
(
	SELECT COUNT(*) AS NrCreatedProcesses, CONVERT(varchar(10), CreatedDate, 121) As Date
	FROM FCProcess
	GROUP BY CONVERT(varchar(10), CreatedDate, 121)
) created ON sessionLog.Date = created.Date
LEFT OUTER JOIN 
(
	SELECT COUNT(*) AS NrFinishedProcesses, CONVERT(varchar(10), FinishedDate, 121) As Date
	FROM FCProcess
	WHERE FinishedDate IS NOT NULL
	GROUP BY CONVERT(varchar(10), FinishedDate, 121)
) finished ON sessionLog.Date = finished.Date
LEFT OUTER JOIN 
(
	SELECT COUNT(*) AS NrApprovedProcesses, CONVERT(varchar(10), ApprovedDate, 121) As Date
	FROM FCProcess
	WHERE ApprovedDate IS NOT NULL
	GROUP BY CONVERT(varchar(10), ApprovedDate, 121)
) approved ON sessionLog.Date = approved.Date
LEFT OUTER JOIN ReportUsageSummary analysisReportUsage ON sessionLog.[Date] = analysisReportUsage.[Date] AND analysisReportUsage.ReportType = 'Analysis Report'
LEFT OUTER JOIN ReportUsageSummary rsReportUsage ON sessionLog.[Date] = rsReportUsage.[Date] AND rsReportUsage.ReportType = 'RS Report'
GO
