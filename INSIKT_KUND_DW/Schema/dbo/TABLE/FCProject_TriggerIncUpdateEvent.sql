SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProject_TriggerIncUpdateEvent](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectID] [int] NULL,
	[FCVersionID] [int] NULL,
	[TriggerEvent_INSIKTProjekt] [bit] NULL,
	[TriggerEvent_Utfall] [bit] NULL,
	[TriggerEvent_Utilities] [bit] NULL,
	[TriggerEvent_Periodisering] [bit] NULL,
	[WaitForEvents] [bit] NULL,
	[UserID] [int] NULL,
	[CreateDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProject_TriggerIncUpdateEvent] ADD  CONSTRAINT [DF_FCProject_TriggerIncUpdateEvent_TriggerEvent_INSIKTProjekt]  DEFAULT ((0)) FOR [TriggerEvent_INSIKTProjekt]
GO
ALTER TABLE [dbo].[FCProject_TriggerIncUpdateEvent] ADD  CONSTRAINT [DF_FCProject_TriggerIncUpdateEvent_TriggerOnEvent_Utfall]  DEFAULT ((0)) FOR [TriggerEvent_Utfall]
GO
ALTER TABLE [dbo].[FCProject_TriggerIncUpdateEvent] ADD  CONSTRAINT [DF_FCProject_TriggerIncUpdateEvent_TriggerOnEvent_Utilities]  DEFAULT ((0)) FOR [TriggerEvent_Utilities]
GO
ALTER TABLE [dbo].[FCProject_TriggerIncUpdateEvent] ADD  CONSTRAINT [DF_FCProject_TriggerIncUpdateEvent_TriggerOnEvent_Periodisering]  DEFAULT ((0)) FOR [TriggerEvent_Periodisering]
GO
ALTER TABLE [dbo].[FCProject_TriggerIncUpdateEvent] ADD  CONSTRAINT [DF_FCproject_TriggerIncUpdateEvent_WaitForEvents]  DEFAULT ((0)) FOR [WaitForEvents]
GO
ALTER TABLE [dbo].[FCProject_TriggerIncUpdateEvent] ADD  CONSTRAINT [DF_FCProject_Event_CreateDate]  DEFAULT (getutcdate()) FOR [CreateDate]
GO
