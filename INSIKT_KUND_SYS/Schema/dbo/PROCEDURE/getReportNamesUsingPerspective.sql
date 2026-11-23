SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Get names of all reports that uses perspective
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Jonas Markström
 #CreateDate:		170407
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE PROCEDURE [dbo].[getReportNamesUsingPerspective] 
		@DataSourceId int,
		@PerspectiveId int
AS
BEGIN
	SELECT Name
	FROM Report 
	WHERE 
	Data.value('(/AnalysisReport/DataSource/DataSourceId)[1]', 'int') = @DataSourceId
	AND
	Data.value('(/AnalysisReport/DataSource/PerspectiveId)[1]', 'int') = @PerspectiveId
	AND
	(Inactive = 0)
	AND
	(IsQuickReport = 0 OR IsQuickReport IS NULL)
END
GO
