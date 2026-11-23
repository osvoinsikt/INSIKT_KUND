SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create VIEW [dbo].[FCProject_TriggerIncUpdateEvent_WaitForEvents] as
select
	[ID] = t.ID
from dbo.FCproject_TriggerIncUpdateEvent t
where
	t.WaitForEvents = 1


GO
