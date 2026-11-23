SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[support_ShowEventLogHighLevelNormalized]
as

set transaction isolation level read uncommitted 
select
	e.ID as EventID
	,e.EventStart
	,e.EventEnd
	,Duration = DATEDIFF(MS, e.EventStart, isnull(e.EventEnd, e.EventStart))
	,e.Title	
	,e.[Description]
	,coalesce(usr.UserName, '[No user]') as UserName
	,e.UserID
from
	EventLog e
	left join UserSecurityGroup usr
		on (e.UserID = usr.UserID)
where ParentEventID is null -- Only show events on highest level (no "child" events)
order by e.EventEnd desc
GO
