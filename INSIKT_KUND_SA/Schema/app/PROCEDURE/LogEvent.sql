SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [app].[LogEvent]
(
	 @ETLID int = null
	,@EventObject nvarchar(255)
	,@EventTitle nvarchar(255) = null
	,@Description nvarchar(max) = null
	,@ParentEventID int = null	
	,@EventType int = 0		
	,@EventUser nvarchar(255) = null
	,@EventStart datetime = null
	,@EventStop datetime = null
	,@LogIDStack varbinary(max) = null output
)
as
set nocount on

if @EventTitle is null set @EventTitle = @EventObject
if @EventUser is null set @EventUser = suser_sname()
if @EventUser is null set @EventUser = convert(sysname, current_user)
if @EventStart is null set @EventStart = getdate()
if @EventStop is null set @EventStop = getdate()

if @ParentEventID is null and @LogIDStack is not null
	set @ParentEventID = CAST(@LogIDStack as int)

if @ParentEventID is null and @ETLID is not null
	begin
		--
		-- Find parent ID
		--
		select
			@ParentEventID = max(ID)
		from
			app.EventLog
		where
			ETLID = @ETLID
			and EventStop is null
			and EventStart <= @EventStart
	end
	

if @ParentEventID is not null and @ETLID is null
	select
		@ETLID = ETLID
	from
		app.EventLog
	where
		ID = @ParentEventID

insert into app.EventLog
(
	 [ETLID]
	,[SPID]
	,[EventUser]
	,[EventType]
	,[EventObject]
	,[EventStart]
	,[EventStop]
	,[EventTitle]
	,[Description]
	,[ParentEventID]
	,[ErrorCount])
values
(
	 @ETLID
	,@@SPID
	,@EventUser
	,@EventType
	,@EventObject
	,@EventStart
	,@EventStop
	,@EventTitle
	,@Description
	,@ParentEventID
	,0	
)

return scope_identity()




GO
