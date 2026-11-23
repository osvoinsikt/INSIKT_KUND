SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SessionTabLogSummary]
AS
SELECT     stl.SessionLogID, sl.UserID, sl.dtLoginTime, COUNT(stl.ID) AS TabCount
FROM         dbo.SessionLog sl
INNER JOIN	 dbo.SessionTabLog stl on stl.SessionLogID = sl.ID
GROUP BY stl.SessionLogID, sl.UserID, dtLoginTime
GO
