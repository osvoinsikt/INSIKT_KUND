SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FCProject_TriggerIncUpdateEvent_TriggerEvent_Utfall] as
select
	[ID] = t.ID
	,[FCProjectID] = t.FCProjectID
from dbo.FCproject_TriggerIncUpdateEvent t
where
	t.TriggerEvent_Utfall = 1


GO
