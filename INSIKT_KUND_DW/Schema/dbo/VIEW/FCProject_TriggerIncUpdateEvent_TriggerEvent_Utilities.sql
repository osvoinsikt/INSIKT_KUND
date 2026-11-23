SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create VIEW [dbo].[FCProject_TriggerIncUpdateEvent_TriggerEvent_Utilities] as
select
	[ID] = t.ID
	,[FCProjectID] = t.FCProjectID
from dbo.FCproject_TriggerIncUpdateEvent t
where
	t.TriggerEvent_Utilities = 1

GO
