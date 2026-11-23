SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jonas Markström
-- Create date: 20190919
-- Description:	Get the number days that the user has logged in for each month within thee time constraints.
-- =============================================
CREATE PROCEDURE [dbo].[selUserUsagesPerMonth] 
	@userID int,
	@from datetime,
	@to datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT YEAR(dtLoginTime) AS [Year], MONTH(dtLoginTime) AS [Month], COUNT (DISTINCT CAST (dtLoginTime AS Date)) AS NrDaysUsed
	FROM SessionLog
	WHERE UserID = @userID AND dtLoginTime > @from AND dtLoginTime < @to
	GROUP BY YEAR(dtLoginTime), MONTH(dtLoginTime)
	ORDER BY YEAR(dtLoginTime), MONTH(dtLoginTime)
END
GO
