SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReportUsageSummary] AS
SELECT CONVERT(varchar(10), OpenedDate, 121) AS Date, ReportType, COUNT(*) As OpenCount FROM UserRecentlyOpenedReportSummary
GROUP BY CONVERT(varchar(10), OpenedDate, 121), ReportType
GO
