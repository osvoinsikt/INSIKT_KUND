SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[support_ShowEventTree]
(
	@EventID int = null,
	@TopCount int = 1000
)
as

set transaction isolation level read uncommitted 
;with
LatestEvent(ID) as
(
	-- Specific event or latest root events.
	select top (@TopCount) ID
	from dbo.EventLog
	where ID = @EventID
		or (@EventID is null and ParentEventID is null)
	order by ID desc
),
EventTree(ID, ParentEventID, TreeLevel, TreeOrder) as
(
	select
		r.ID
		,r.ParentEventID
		,0
		,right('000000000000' + cast(r.ID as varchar(12)), 12)
	from
		EventLog r
	join
		LatestEvent latest on latest.ID = r.ID
	
	union all
	
	select
		e.ID
		,e.ParentEventID
		,pe.TreeLevel + 1
		,pe.TreeOrder
	from
		EventLog e
			inner join EventTree pe on
				pe.ID = e.ParentEventID	
)
select
	e.ID
	,[Start]=e.EventStart
	,[End]=e.EventEnd
	,Duration = DATEDIFF(MS, e.EventStart, isnull(e.EventEnd, e.EventStart))
	,Title = space(t.TreeLevel * 5) + e.Title	
	,e.Description	
	,coalesce(usr.UserName, '[No user]') as UserName
	,e.UserID
	,EventID = t.ID
	,ParentEventID = t.ParentEventID
from
	EventTree t
		inner join EventLog e on
			e.ID = t.ID
		left join UserSecurityGroup usr
			on (e.UserID = usr.UserID)
order by
	TreeOrder desc, ID
GO
