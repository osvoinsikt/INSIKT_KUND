SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure integrationInternal.EndpointUsageLogStart
(	
	@Endpoint varchar(128)
	,@CallingProcedure varchar(128)
	,@LogID int = null output
)
as

insert into integrationInternal.EndpointUsageLog([Endpoint], CallingProcedure, StartDate, UserName)
values(@Endpoint, @CallingProcedure, GETUTCDATE(), suser_sname())

select @LogID = SCOPE_IDENTITY()

return @LogID

GO
