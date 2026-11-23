SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FCProject_TriggerIncUpdateEvent_TriggerEvent_INSIKTProjekt] as
select
	[ID] = t.ID
	,[FCProjectID] = t.FCProjectID
from dbo.FCProject_TriggerIncUpdateEvent t
where 
	t.TriggerEvent_INSIKTProjekt = 1


GO
