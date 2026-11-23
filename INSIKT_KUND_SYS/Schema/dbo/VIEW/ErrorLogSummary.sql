SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ErrorLogSummary]
AS
SELECT        CONVERT(varchar(10), dbo.ErrorLog.EventDate, 121) AS EventDate, MIN(CONVERT(varchar, dbo.ErrorLog.EventDate, 108)) AS FirstAtTime, MAX(CONVERT(varchar, dbo.ErrorLog.EventDate, 108)) AS LastAtTime, 
							COUNT(dbo.ErrorLog.ID) AS Count, dbo.ErrorLog.UserName, dbo.LogLevel.Name AS [Level], CAST(dbo.ErrorLog.ErrorMessage AS varchar(MAX)) AS ErrorMessage, 
							CAST(dbo.ErrorLog.StackTrace AS varchar(MAX)) AS StackTrace
FROM            dbo.ErrorLog LEFT OUTER JOIN
							dbo.LogLevel ON dbo.ErrorLog.ErrorLogLevelID = dbo.LogLevel.ID
WHERE        (CAST(dbo.ErrorLog.ErrorMessage AS varchar(MAX)) NOT LIKE 'Thread was being aborted.') AND (CAST(dbo.ErrorLog.ErrorMessage AS varchar(MAX)) NOT LIKE 'Drillthrough is not supported on this measure') AND
							(CAST(dbo.ErrorLog.ErrorMessage AS varchar(MAX)) NOT LIKE 'You cannot drillthrough if the cell in a select clause is a calculated cell.') AND (DATEDIFF(dd, dbo.ErrorLog.EventDate, GETUTCDATE()) < 365)
GROUP BY dbo.ErrorLog.UserName, CAST(dbo.ErrorLog.ErrorMessage AS varchar(MAX)), CAST(dbo.ErrorLog.StackTrace AS varchar(MAX)), CONVERT(varchar(10), dbo.ErrorLog.EventDate, 121), dbo.LogLevel.Name
GO
