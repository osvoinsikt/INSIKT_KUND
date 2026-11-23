SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*******************************************************************
 #Desc: 		Selects number of distinct users logged in per hour and date.
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Adam Holmström
 #CreateDate:		111012
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
--EXEC [selLoggedInUsersPerHourAndDate] '2011-10-03', '2011-10-06'
CREATE           Procedure [dbo].[selLoggedInUsersPerHourAndDate]
	@startDate datetime,
	@stopDate datetime
AS

WITH Dates AS
(       
	SELECT @startDate as [Date]
	UNION ALL
	SELECT DATEADD(hour, 1, [Date])       
	FROM   Dates 
	WHERE  DATEADD(hour, 1, [Date]) < DATEADD(day, 1, @stopDate)
)
SELECT CONVERT(varchar(10), [Date], 121) As [Date], DATEPART(hour, [Date]) As [Time], 
	(
		SELECT COUNT(distinct UserID) 
		FROM SessionLog 
		WHERE CONVERT(varchar(10), [Date], 121) = CONVERT(varchar(10), dtLoginTime, 121)
			AND DATEPART(hour, dtLoginTime) <= DATEPART(hour, [Date])
			AND DATEPART(hour, ISNULL(dtLogoutTime, dtLoginTime)) >= DATEPART(hour, [Date])
	) AS DistinctUserCount
FROM Dates

--DECLARE @date datetime = '2011-10-07 11:00'
--SELECT *
--		FROM SessionLog 
--		WHERE CONVERT(varchar(10), @date, 121) = CONVERT(varchar(10), dtLoginTime, 121)
--			AND DATEPART(hour, dtLoginTime) <= DATEPART(hour, @date)
--			AND DATEPART(hour, ISNULL(dtLogoutTime, dtLoginTime)) >= DATEPART(hour, @date)
GO
