SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure dbo.setTimeZoneForUser
	@userID int,
	@timeZone varchar(50)
as
begin
	update UserSecurityGroup
	set TimeZone = @timeZone
	where UserID = @userID
end
GO
