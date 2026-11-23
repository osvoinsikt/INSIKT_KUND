SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[IncUpdate_EventConfiguration](
	[EventID] [int] IDENTITY(1,1) NOT NULL,
	[JobID] [int] NOT NULL,
	[Name] [nvarchar](1024) NULL,
	[Description] [nvarchar](max) NULL,
	[EventTriggerTypeID] [varchar](100) NOT NULL,
	[TriggerTable] [nvarchar](1024) NULL,
	[TriggerTableFilter] [nvarchar](max) NULL,
	[TriggerIdColumnName] [nvarchar](max) NULL,
	[CustomTriggerQuery] [nvarchar](max) NULL,
	[CalculateProcedureDescription] [nvarchar](max) NULL,
	[CalculateProcedure] [nvarchar](1024) NULL,
	[PostEventBatchProcedure] [nvarchar](max) NULL,
	[EventOrder] [int] NULL,
	[EventPrio] [int] NOT NULL,
	[IsDisabled] [bit] NOT NULL,
 CONSTRAINT [PK_IncUpdate_EventConfiguration] PRIMARY KEY CLUSTERED 
(
	[EventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [app].[IncUpdate_EventConfiguration] ADD  CONSTRAINT [DF_IncUpdate_EventConfiguration_EventOrder]  DEFAULT ((10)) FOR [EventOrder]
GO
ALTER TABLE [app].[IncUpdate_EventConfiguration] ADD  CONSTRAINT [DF_IncUpdate_EventConfiguration_EventPrio]  DEFAULT ((1)) FOR [EventPrio]
GO
ALTER TABLE [app].[IncUpdate_EventConfiguration] ADD  CONSTRAINT [DF_IncUpdate_EventConfiguration_IsDisabled]  DEFAULT ((0)) FOR [IsDisabled]
GO
ALTER TABLE [app].[IncUpdate_EventConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_IncUpdate_EventConfiguration_EventTriggerType] FOREIGN KEY([EventTriggerTypeID])
REFERENCES [app].[IncUpdate_EventTriggerType] ([EventTriggerTypeID])
GO
ALTER TABLE [app].[IncUpdate_EventConfiguration] CHECK CONSTRAINT [FK_IncUpdate_EventConfiguration_EventTriggerType]
GO
ALTER TABLE [app].[IncUpdate_EventConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_IncUpdate_EventConfiguration_IncUpdate_Job] FOREIGN KEY([JobID])
REFERENCES [app].[IncUpdate_Job] ([JobID])
GO
ALTER TABLE [app].[IncUpdate_EventConfiguration] CHECK CONSTRAINT [FK_IncUpdate_EventConfiguration_IncUpdate_Job]
GO
