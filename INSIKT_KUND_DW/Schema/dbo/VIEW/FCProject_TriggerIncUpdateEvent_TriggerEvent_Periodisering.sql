SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FCProject_TriggerIncUpdateEvent_TriggerEvent_Periodisering] as
select
	[ID] = t.ID
	,[FCProjectID] = t.FCProjectID
	,[FCVersionID] = t.FCVersionID
from dbo.FCproject_TriggerIncUpdateEvent t
where
	t.TriggerEvent_Periodisering = 1


GO
