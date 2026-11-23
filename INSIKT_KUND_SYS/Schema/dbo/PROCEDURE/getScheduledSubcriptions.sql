SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[getScheduledSubcriptions]
AS
	/* SET NOCOUNT ON */
	SELECT SubscriptionID, sub.Name, Period, Day, HourOfDay, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
	FROM Schedule
	INNER JOIN SubscriptionScheduleRelation On ScheduleID = Schedule.ID
	INNER JOIN Subscription sub ON SubscriptionID = sub.ID
	WHERE Period = 'day'

	SELECT SubscriptionID, sub.Name, Period, Day, HourOfDay, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
	FROM Schedule
	INNER JOIN SubscriptionScheduleRelation On ScheduleID = Schedule.ID
	INNER JOIN Subscription sub ON SubscriptionID = sub.ID
	WHERE Period = 'week'

	SELECT SubscriptionID, sub.Name, Period, Day, HourOfDay, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
	FROM Schedule
	INNER JOIN SubscriptionScheduleRelation On ScheduleID = Schedule.ID
	INNER JOIN Subscription sub ON SubscriptionID = sub.ID
	WHERE Period = 'month'

	RETURN 

	
GO
