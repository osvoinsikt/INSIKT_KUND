SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Removes old rows in the database.
 #Used By:			-
 #Creator:			Anton Vermcrantz
 #CreateDate:		190710
 #Modified by:		William Vesterberg
 #ModifiedDate:		260316
 #Change history
	--200708  - Anton Vermcrantz - Added maintenance for UpgradeJob and UpgradeJobLog and added @1YearAgoAnd1Day
    --220909  - Kristoffer Granberg - 
	--231221  - Oskar Lyxell - Added delete for notifications older than 90 days
	--240531  - Anders Gustafsson - Added removal of older rows in WebDavDocument and randomizing of new Guids for Document
    --260316  - William Vesterberg - Added delete for GeneralApiUsageLog older than 90 days
	--260806  - Added cleanup for AIChatLogFCRecentSelection/AIToolCallLog
 #Log:

********************************************************************/
CREATE PROCEDURE [dbo].[Maintenance]
	/* Database to perform index maintenance on as comma separated string */
	@indexMaintenaceDatabases VARCHAR(255) = NULL
AS
BEGIN
	-- 1 week ago
	DECLARE @1WeekAgo AS DATETIME = (GETUTCDATE() - 7)
	-- 1 month ago
	DECLARE @1MonthAgo AS DATETIME = DATEADD(MONTH, -1, GETUTCDATE())
	-- 3 months ago
	DECLARE @3MonthsAgo AS DATETIME = (GETUTCDATE() - 90)
	-- 1 year with 1 leap year
	DECLARE @1YearAgo AS DATETIME = (GETUTCDATE() - 366)
	-- 1 year with 1 leap year and 1 extra day
	DECLARE @1YearAgoAnd1Day AS DATETIME = (GETUTCDATE() - 367)
	-- 1 and a half year with 1 leap year
	DECLARE @18MonthsAgo AS DATETIME = (GETUTCDATE() - 549)
	-- 5 years with 2 leap years
	DECLARE @5YearsAgo AS DATETIME = (GETUTCDATE() - 1827)

	--Clean ErrorLog
	DELETE FROM ErrorLog
	WHERE EventDate < @1YearAgo

	--Clean FileUploadErrorLog
	DELETE fuel
	FROM FileUploadErrorLog fuel
		INNER JOIN FileUpload fu on fu.ID = fuel.FileUploadID
		INNER JOIN Document d on d.ID = fu.DocumentID
	WHERE d.UploadedDate < @1YearAgo

	DELETE FROM SessionTabLog
	WHERE CreationTime < @1YearAgo

	--Clean SessionLog and recent selections for more than 5 year old data. Will count for two leapYears
	DELETE FROM SessionLog
	WHERE dtLoginTime < @5YearsAgo

	DELETE FROM UserRecentlyUsedReport
	WHERE OpenedDate < @5YearsAgo

	-- AIChatLogFCRecentSelection has an FK to FCRecentSelection, so it must be cleared first.
	-- We clear the corresponding rows in AIChatLog at the same time.
	SELECT ID INTO #FCRecentSelectionToDelete
	FROM FCRecentSelection
	WHERE SelectedDate < @5YearsAgo

	SELECT ID, AIChatLogID INTO #AIChatLogFCRecentSelectionToDelete
	FROM AIChatLogFCRecentSelection
	WHERE FCRecentSelectionID IN (SELECT ID FROM #FCRecentSelectionToDelete)

	DELETE AIChatLogFCRecentSelection
	WHERE ID IN (SELECT ID FROM #AIChatLogFCRecentSelectionToDelete)

	DELETE AIChatLog
	WHERE ID IN (SELECT AIChatLogID FROM #AIChatLogFCRecentSelectionToDelete)
		AND NOT EXISTS (SELECT 1 FROM AIChatLogFCRecentSelection WHERE AIChatLogID = AIChatLog.ID)
		AND NOT EXISTS (SELECT 1 FROM AIChatLogReportViewLog WHERE AIChatLogID = AIChatLog.ID)

	DROP TABLE #AIChatLogFCRecentSelectionToDelete

    DELETE FROM FCRecentSelection
    WHERE ID IN (SELECT ID FROM #FCRecentSelectionToDelete)

	DROP TABLE #FCRecentSelectionToDelete

    DELETE FROM scorecard.UserRecentSelection
    WHERE OpenedDate < @5YearsAgo

	SELECT ID INTO #ReportViewLogToDelete
	FROM ReportViewLog
	WHERE EventDate < @1YearAgo

	-- AIChatLogReportViewLog has an FK to ReportViewLog, so it must be cleared first.
	-- We clear the corresponding rows in AIChatLog at the same time.
	SELECT ID, AIChatLogID INTO #AIChatLogReportViewLogToDelete
	FROM AIChatLogReportViewLog
	WHERE ReportViewLogID IN (select ID FROM #ReportViewLogToDelete)

	DELETE AIChatLogReportViewLog
	WHERE ID IN (SELECT ID FROM #AIChatLogReportViewLogToDelete)

	DELETE AIChatLog
	WHERE ID IN (SELECT AIChatLogID FROM #AIChatLogReportViewLogToDelete)
		AND NOT EXISTS (SELECT 1 FROM AIChatLogFCRecentSelection WHERE AIChatLogID = AIChatLog.ID)
		AND NOT EXISTS (SELECT 1 FROM AIChatLogReportViewLog WHERE AIChatLogID = AIChatLog.ID)

	DROP TABLE #AIChatLogReportViewLogToDelete

	DELETE FROM ReportViewLog
	WHERE ID IN (select ID FROM #ReportViewLogToDelete)

	DROP TABLE #ReportViewLogToDelete

	DELETE FROM FCObjectViewLog
	WHERE EventDate < @1YearAgo

	-- AIToolCallLog is a short-lived audit log of AI tool invocations, same retention as other view logs.
	DELETE FROM AIToolCallLog
	WHERE CreatedDate < @3MonthsAgo

	DELETE FROM AdminPageViewLog
	WHERE EventDate < @1YearAgo

	DELETE FROM ServiceJob
	WHERE CreatedDate < @1YearAgo

	-- UpgradeJobLog need to be cleared before UpgradeJob because of FK. 
	-- Becuase of this and that a log row paired with a upgradeJob can be created later one day is added to the UpgradeJob maintenance
	DELETE FROM UpgradeJobLog
	WHERE EventDate < @1YearAgo
	DELETE FROM UpgradeJob
	WHERE DateCreated < @1YearAgoAnd1Day 

	DELETE FROM ServiceLog
	WHERE EventDate < @1YearAgo

	DELETE FROM InsiktServiceReportMetaDataLog
	WHERE ReportedDate < @1YearAgo

	SELECT ID
	INTO #LoginDeviceToRemove
	FROM UserSecurityGroupLoginDevice
	WHERE LastLoginDate < @18MonthsAgo

	-- Remove old failed logins...
	DELETE UserSecurityGroupFailedLogin 
	WHERE LoginAttemptDate < @1YearAgo

	-- ... but for more recent failed logins, remove the connections to specific login devices that are
	-- being removed, so that the devices can be removed without FK error. But keep the log of recent
	-- failed logins for purposes of security auditing.
	UPDATE UserSecurityGroupFailedLogin
	SET LoginDeviceID = NULL
	WHERE LoginDeviceID IN (SELECT ID FROM #LoginDeviceToRemove)

	DELETE FROM UserSecurityGroupLoginDevice
	WHERE ID IN (SELECT ID FROM #LoginDeviceToRemove)

	DROP TABLE #LoginDeviceToRemove

	SELECT ID
	INTO #MailLogToDelete
	FROM MailLog
	WHERE DateCreated < @1YearAgo

	DELETE doc
	FROM MailLogDocumentRelation doc
		JOIN #MailLogToDelete del on del.ID = doc.MailLogID

	DELETE mail
	FROM MailLog mail
		JOIN #MailLogToDelete del on del.ID = mail.ID

	DROP TABLE #MailLogToDelete

	-- In case a parent event would be removed, but a child event kept, then both are kept.
	;WITH ToKeep AS (
		SELECT ID, ParentEventID
		FROM EventLog
		WHERE EventStart >= @1YearAgo
		UNION ALL
		SELECT e.ID, e.ParentEventID
		FROM EventLog e
			JOIN ToKeep child on child.ParentEventID = e.ID
		WHERE e.EventStart >= @1YearAgo or child.ID IS NOT NULL
	)
	DELETE FROM EventLog
	WHERE ID NOT IN (SELECT ID FROM ToKeep)

	IF @indexMaintenaceDatabases IS NOT NULL
		EXEC dbo.IndexOptimize @Databases = @indexMaintenaceDatabases,
			@FragmentationLow = NULL,
			@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
			@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
			@FragmentationLevel1 = 5,
			@FragmentationLevel2 = 30,
			@UpdateStatistics = 'ALL',
			@OnlyModifiedStatistics = 'Y'

	-- DELETE unreferenced documents
	EXEC MaintenanceDocument

	-- DELETE documentRevision and documentData
	-- if there is more then 10 files and the files are older then 30days.
	EXEC MaintenanceFileData

	DELETE FROM dbo.DataSourceLog
	WHERE EventTime < @3MonthsAgo

    -- Delete scorecard KPI integration service jobs older than 3 months.
	-- We want to clear this job type more often because they can quickly add up.
	-- Each entered value in INSIKT on a KPI with integration activated will queue a job of this type.
    DELETE FROM dbo.ServiceJob
    WHERE ServiceJobTypeID = 7 AND CreatedDate < @3MonthsAgo

    -- Delete scorecard KPI integration execution logs older than 3 months
    SELECT ID into #integrationExecutionsToRemove FROM scorecard.KPIIntegrationExecution
    WHERE StartTime < @3MonthsAgo

    DELETE FROM scorecard.KPIIntegrationExecutionLog
    WHERE ExecutionID in (SELECT ID FROM #integrationExecutionsToRemove)

    DELETE FROM scorecard.KPIIntegrationExecution
    WHERE ID in (SELECT ID FROM #integrationExecutionsToRemove)

    DROP TABLE #integrationExecutionsToRemove
	
	-- Delete notifications older than 90 days. 
	DELETE FROM dbo.Notification WHERE CreatedDate < @3MonthsAgo

	-- AITokenUsage has no simple EventDate column.
	-- Delete data points older than the target month.
	DECLARE @1YearAgoYear INT = DATEPART(YEAR, @1YearAgo)
	DECLARE @1YearAgoMonth INT = DATEPART(MONTH, @1YearAgo)
	DELETE FROM AITokenUsage WHERE Year < @1YearAgoYear OR (Year = @1YearAgoYear AND Month < @1YearAgoMonth)

	-- Delete GeneralApi-logs older than 90 days. 
	DELETE FROM api.GeneralApiUsageLog WHERE TimestampUtc < @3MonthsAgo

	-- Delete rows in WebDavDocument that is older than 1 month
	DELETE FROM WebDavDocument WHERE CreatedAt < @1MonthAgo

	-- Rotate Guids for Documents that were created more than one week ago
	UPDATE Document
		SET GUID = NEWID()
	WHERE UploadedDate < @1WeekAgo

END

GO
