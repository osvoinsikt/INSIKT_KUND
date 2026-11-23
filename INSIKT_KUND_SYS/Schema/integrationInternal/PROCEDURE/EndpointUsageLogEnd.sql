SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure integrationInternal.EndpointUsageLogEnd
(	
	@LogID int
)
as

update integrationInternal.EndpointUsageLog
set EndDate = GETUTCDATE()
where ID = @LogID

GO
