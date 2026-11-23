SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from DSS_ShowEventTree order by TreeOrder
CREATE procedure [app].[ShowEventTree] 
(
	@ETLID int = null
)
as
if @ETLID is null
	select @ETLID = max(ETLID) from EventLog

set transaction isolation level read uncommitted 
;with EventTree(ID, ParentEventID, TreeLevel, TreeOrder) as
(
	select
		r.ID
		,r.ParentEventID
		,0
		,cast
		(		
			right('000000000000' + cast(coalesce(r.ETLID, 0) as varchar(12)), 12) + 
			right('000000000000' + cast(r.ID as varchar(12)), 12)
			as varchar(8000)
		)
	from
		EventLog r with(nolock)
	where
		r.ETLID = @ETLID
		and r.ParentEventID is null
	
	union all
	
	select
		e.ID
		,e.ParentEventID
		,pe.TreeLevel + 1
		,pe.TreeOrder + right('000000000000' + cast(e.ID as varchar(12)), 12)
	from
		EventLog e with(nolock)
			inner join EventTree pe on
				pe.ID = e.ParentEventID	
	where
		e.ETLID = @ETLID
)
select
	e.ETLID
	,e.EventStart
	,e.EventStop
	,Duration = DATEDIFF(ss, e.EventStart, isnull(e.EventStop, GETDATE()))
	,TreeTitle = space(t.TreeLevel * 5) + e.EventTitle		
	,e.Description
	,e.EventObject				
	
	
	
	,e.ErrorCount
	,err.ErrorMessage
	,err.ErrorProcedure
	,e.SPID
	,e.EventUser
	,e.EventType	
	
	,e.EventTitle
	,EventID = t.ID
	,ParentEventID = t.ParentEventID
from
	EventTree t with(nolock)
		inner join EventLog e on
			e.ID = t.ID			
		left join ErrorLog err on
			err.EventID = e.ID
order by
	TreeOrder
GO
