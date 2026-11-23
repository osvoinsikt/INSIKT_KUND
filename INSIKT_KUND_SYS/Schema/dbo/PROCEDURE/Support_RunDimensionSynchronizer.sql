SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Tells INSIKTService to run DimensionSynchronizer.

	There are three modes of execution:
	* Sync a specific FCType by specifying @fcTypeID. This mode will only sync CompanyID = 1.
	  Since there is normally only one Company, this usually works.
	* Synchronize a specific Scorecard organisation by specifying @scorecardOrganisationID.
	* Synchronize everything that can be synchronized by leaving both parameters unset.
	  This will sync all FCTypes and Scorecard organisations. This will also sync all Companies if
	  there is more than one, so this is the way to go if needing to sync multiple companies.

	To sync a specific FCType:
	exec Support_RunDimensionSynchronizer @fcTypeID = 3

	To sync a specific Scorecard organisation:
	exec Support_RunDimensionSynchronizer @scorecardOrganisationID = 3

	To sync everything:
	exec Support_RunDimensionSynchronizer
*/
CREATE procedure [dbo].[Support_RunDimensionSynchronizer]
	-- Set this to sync a specific FCType
	@fcTypeID int = null,

	-- Set this to sync a specific Scorecard organisation
	@scorecardOrganisationID int = null
as
begin
	declare @fcTypeString varchar(10) = isnull(cast(@fcTypeID as varchar), 'null')
	declare @scorecardString varchar(10) = isnull(cast(@scorecardOrganisationID as varchar), 'null')

	declare @json varchar(max) = '
		{
			"FCTypeId":' + @fcTypeString + ',
			"ScorecardOrganisationID":' + @scorecardString + '
		}'

	insert into ServiceJob(ServiceJobTypeID, Body, CreatedBy, CreatedDate, NotifyUserTypeID)
	values (1, @json, -1, getutcdate(), 1)
end
GO
