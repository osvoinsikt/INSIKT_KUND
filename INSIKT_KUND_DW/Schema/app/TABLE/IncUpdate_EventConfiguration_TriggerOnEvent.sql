SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[IncUpdate_EventConfiguration_TriggerOnEvent](
	[Trigger_IncUpdateEventID] [int] NOT NULL,
	[When_IncUpdateEventID] [int] NOT NULL,
 CONSTRAINT [PK_IncUpdate_EventConfiguration_TriggerOnEvent] PRIMARY KEY CLUSTERED 
(
	[Trigger_IncUpdateEventID] ASC,
	[When_IncUpdateEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [app].[IncUpdate_EventConfiguration_TriggerOnEvent]  WITH CHECK ADD  CONSTRAINT [FK_IncUpdate_EventConfiguration_TriggerOnEvent_Trigger] FOREIGN KEY([Trigger_IncUpdateEventID])
REFERENCES [app].[IncUpdate_EventConfiguration] ([EventID])
GO
ALTER TABLE [app].[IncUpdate_EventConfiguration_TriggerOnEvent] CHECK CONSTRAINT [FK_IncUpdate_EventConfiguration_TriggerOnEvent_Trigger]
GO
ALTER TABLE [app].[IncUpdate_EventConfiguration_TriggerOnEvent]  WITH CHECK ADD  CONSTRAINT [FK_IncUpdate_EventConfiguration_TriggerOnEvent_When] FOREIGN KEY([When_IncUpdateEventID])
REFERENCES [app].[IncUpdate_EventConfiguration] ([EventID])
GO
ALTER TABLE [app].[IncUpdate_EventConfiguration_TriggerOnEvent] CHECK CONSTRAINT [FK_IncUpdate_EventConfiguration_TriggerOnEvent_When]
GO
