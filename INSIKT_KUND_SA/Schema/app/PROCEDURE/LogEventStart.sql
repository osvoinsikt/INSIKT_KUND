SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [app].[LogEventStart]
(
	
	
	@EventObject nvarchar(255)
	,@EventTitle nvarchar(255) = null
	,@Description nvarchar(max) = null
	,@EventIDStack varbinary(max) = null output	
	,@EventType int = 0	
	,@EventUser nvarchar(255) = null	
	,@EventStart datetime = null
	
	,@ParentEventID int = null
	,@ETLID int = null output
)
as
set nocount on;
if @EventTitle is null set @EventTitle = @EventObject
if @EventUser is null set @EventUser = suser_sname()
if @EventUser is null set @EventUser = convert(sysname, current_user)
if @EventStart is null set @EventStart = getdate()


declare @LogID int


--
-- When @@EventIDStack is not null @ParentEventID is ignored
--
if @EventIDStack is not null
	set @ParentEventID = CAST(@EventIDStack as int)

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


begin tran

if @ETLID is null
	select 
		@ETLID = coalesce(max(ETLID), 0) + 1
	from
		app.EventLog
				

insert into app.EventLog
(
	[ETLID]
	,[SPID]
	,[EventUser]
	,[EventType]
	,[EventObject]
	,[EventStart]
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
	,@EventTitle
	,@Description
	,@ParentEventID
	,0	
)
select @LogID = SCOPE_IDENTITY()

commit tran

exec app.StackPushInt @LogID, @EventIDStack out

return @LogID




GO
