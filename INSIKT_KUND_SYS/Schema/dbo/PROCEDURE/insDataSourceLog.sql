SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Log data source events
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Andreas Nording
 #CreateDate:		071017
 #Modified by:		THRO
 #ModifiedDate:		171031

 #Log: 171031 - Updated to conform to format where the connection is per measure group instead of data source

********************************************************************/
CREATE	Procedure [dbo].[insDataSourceLog]
	@nDataSourceMeasureGroupID int
	,@dtEventTime datetime
	,@dtDataUpdatedTime datetime
	,@nStatus int
	,@vsMessage nvarchar(500) = null
	
AS
BEGIN
INSERT INTO [dbo].[DataSourceLog]
	([DataSourceMeasureGroupID]
	,[EventTime]
	,[DataUpdatedTime]
	,[LogStatusTypeID]
	,[Message])
VALUES
	(@nDataSourceMeasureGroupID
	,@dtEventTime
	,@dtDataUpdatedTime
	,@nStatus
	,@vsMessage)
END

GO
