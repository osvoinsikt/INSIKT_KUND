SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[SaEventLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ETLID] [int] NULL,
	[SPID] [int] NOT NULL,
	[EventUser] [nvarchar](255) NOT NULL,
	[EventType] [int] NOT NULL,
	[EventObject] [nvarchar](255) NOT NULL,
	[EventStart] [datetime] NOT NULL,
	[EventStop] [datetime] NULL,
	[EventTitle] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ParentEventID] [int] NULL,
	[ErrorCount] [int] NOT NULL,
 CONSTRAINT [PK_EventLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_app_SaEventLog_ETLID] ON [app].[SaEventLog]
(
	[ETLID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [app].[SaEventLog] ADD  CONSTRAINT [DF_EventLog_EventType]  DEFAULT ((0)) FOR [EventType]
GO
ALTER TABLE [app].[SaEventLog] ADD  CONSTRAINT [DF_EventLog_EventStart]  DEFAULT (getdate()) FOR [EventStart]
GO
ALTER TABLE [app].[SaEventLog] ADD  CONSTRAINT [DF_EventLog_ErrorCount]  DEFAULT ((0)) FOR [ErrorCount]
GO
