SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SessionLogSummary]
AS
SELECT     CONVERT(varchar(10), sl.dtLoginTime, 121) AS Date, COUNT(DISTINCT UserID) AS UserCount, 
		   case when COUNT(stl.ID) = 0 then 1 else cast(COUNT(stl.ID) as decimal) / COUNT(sl.ID) end AS AverageTabCount
FROM         dbo.SessionLog sl
LEFT JOIN	 dbo.SessionTabLog stl on stl.SessionLogID = sl.ID
GROUP BY CONVERT(varchar(10), sl.dtLoginTime, 121)
GO
