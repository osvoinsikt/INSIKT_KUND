SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jonas Markström
-- Create date: 
-- Description:	Returns all distributions that match FCTypeID, CompanyID and the provided filters.
-- =============================================
CREATE PROCEDURE [dbo].[selDistributions] 
	@FCTypeID int,
	@CompanyID int,
	@Filters nvarchar(1500) = ''
AS
BEGIN

	----------- Split the filters ------------
	CREATE TABLE #splitFilters (filterStr VARCHAR(200))

	INSERT INTO #splitFilters(filterStr)
		SELECT strings
		FROM dbo.sepstring(@Filters, '¤')
		WHERE strings <> ''
	---------------------------------------------

	--------- Filter the distributions ----------
	CREATE TABLE #filteredDistributions (PeriodicDistributionID int PRIMARY KEY)

	-- We prepare the filter table with the distributions that have the correct FCTypeID 
	-- and CompanyID. This will soon be filtered down further.
	INSERT INTO #filteredDistributions
	SELECT ID
	FROM FCElementPeriodicDistribution
	WHERE FCTypeID = @FCTypeID AND CompanyID = @CompanyID

	CREATE TABLE #temp (PeriodicDistributionID int PRIMARY KEY)
	CREATE TABLE #intersection (PeriodicDistributionID int PRIMARY KEY)

	DECLARE @curFilterStr VARCHAR(200)
	DECLARE @dimension VARCHAR(200)
	DECLARE @key VARCHAR(200)

	DECLARE c CURSOR FOR
	SELECT filterStr From #splitFilters
	OPEN c
	FETCH NEXT FROM c INTO @curFilterStr
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @dimension = SUBSTRING(@curFilterStr, 0, CHARINDEX('=', @curFilterStr))
		SET @key = SUBSTRING(@curFilterStr, CHARINDEX('=', @curFilterStr) + 1, LEN(@curFilterStr))

		-- Insert the distirbutions matching the current filter in #temp.
		TRUNCATE TABLE #temp
		INSERT INTO #temp
			SELECT PeriodicDistributionID
			FROM FCElementPeriodicDistributionDimension
			WHERE DimensionName = @dimension and ElementKey = @key

		-- We do a intersection between the previously filtered distributions (#filteredDistributions) 
		-- and the filtered distributions for the current filter (#temp).
		TRUNCATE TABLE #intersection
		INSERT INTO #intersection 
			SELECT PeriodicDistributionID FROM #temp
			INTERSECT
			SELECT PeriodicDistributionID FROM #filteredDistributions

		-- Then #intersection is loaded into #filteredDistributions. Now #filteredDistributions contains
		-- the distributions which  filtered by 
		TRUNCATE TABLE #filteredDistributions
		INSERT INTO #filteredDistributions 
			SELECT PeriodicDistributionID FROM #intersection

		FETCH NEXT FROM c INTO @curFilterStr
	END
	CLOSE c
	DEALLOCATE c
	---------------------------------------------------

	-- Select the filtered periodic distributions in first table. Join on predefined periodic distribution and revision.
	SELECT 
		d.*, 
		ppd.Name AS PredefinedName, 
		ppd.Description AS PredefinedDescription,
		ppd.CurrentRevisionID AS PredefinedCurrentRevisionID,
		ppdr.CopyMeasureUniqueName AS PredefinedRevisionCopyMeasureUniqueName,
		ppdr.PeriodPercent1 AS RevisionPeriodPercent1,
		ppdr.PeriodPercent2 AS RevisionPeriodPercent2,
		ppdr.PeriodPercent3 AS RevisionPeriodPercent3,
		ppdr.PeriodPercent4 AS RevisionPeriodPercent4,
		ppdr.PeriodPercent5 AS RevisionPeriodPercent5,
		ppdr.PeriodPercent6 AS RevisionPeriodPercent6,
		ppdr.PeriodPercent7 AS RevisionPeriodPercent7,
		ppdr.PeriodPercent8 AS RevisionPeriodPercent8,
		ppdr.PeriodPercent9 AS RevisionPeriodPercent9,
		ppdr.PeriodPercent10 AS RevisionPeriodPercent10,
		ppdr.PeriodPercent11 AS RevisionPeriodPercent11,
		ppdr.PeriodPercent12 AS RevisionPeriodPercent12
	FROM FCElementPeriodicDistribution d
	JOIN #filteredDistributions f ON (d.ID = f.PeriodicDistributionID)
	LEFT OUTER JOIN FCPredefinedPeriodicDistribution ppd ON (d.PredefinedID = ppd.ID)
	LEFT OUTER JOIN FCPredefinedPeriodicDistributionRevision ppdr ON (d.PredefinedRevisionID = ppdr.ID)

	-- Select the dimension connections in the second table.
	SELECT dd.PeriodicDistributionID, dd.DimensionName, dd.ElementKey
	FROM FCElementPeriodicDistributionDimension dd
	JOIN #filteredDistributions f ON (dd.PeriodicDistributionID = f.PeriodicDistributionID)
	ORDER BY dd.PeriodicDistributionID
END
GO
