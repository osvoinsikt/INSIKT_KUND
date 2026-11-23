SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Tells INSIKTService to run SharePointSynchronizer. When executed only the project properties are synced and not the documents.

	There are two modes of execution:
	* Sync a specific project by specifying @projectID. If the project does not already exist in SharePoint the project will be created.
	* Sync all projects that already exist in SharePoint by not specifying @projectID.

	To sync a specific project:
	exec Support_RunSharePointSync @projectID = 1

	To sync all projects that exist in SharePoint:
	exec Support_RunSharePointSync
*/
CREATE procedure [dbo].[Support_RunSharePointSync]
	-- Set this to sync a specific project
	@projectID int = null
as
begin
	-- ProjectIds is either an array of IDs, or null.
	declare @projectIDs varchar(10) = iif(@projectID is not null, '[' + cast(@projectID as varchar) + ']', 'null')

	-- Update the last-sync timestamp if doing a complete sync.
	declare @shouldUpdateLastSync varchar(10) = iif(@projectID is null, 'true', 'false')

	declare @json varchar(max) = '
		{
			"ProjectIds":' + @projectIDs + ',
			"ShouldUpdateLastSync":' + @shouldUpdateLastSync + '
		}'

	insert into ServiceJob(ServiceJobTypeID, Body, CreatedBy, CreatedDate, NotifyUserTypeID)
	values (6, @json, -1, getutcdate(), 1)
end
GO
