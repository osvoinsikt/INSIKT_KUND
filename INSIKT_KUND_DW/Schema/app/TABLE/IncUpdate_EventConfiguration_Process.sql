SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[IncUpdate_EventConfiguration_Process](
	[EventID] [int] NOT NULL,
	[Name] [varchar](512) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[LinkedServer] [nvarchar](1024) NULL,
	[CubeDatabaseID] [nvarchar](1024) NULL,
	[DataSourceID] [nvarchar](1024) NULL,
	[CubeID] [nvarchar](1024) NULL,
	[MeasureGroupID] [nvarchar](1024) NULL,
	[PartitionID] [nvarchar](1024) NULL,
	[WriteEnabledMeasuregroup] [bit] NULL,
	[CustomSourceTable] [nvarchar](1024) NULL,
	[CustomSourceFilter] [nvarchar](max) NULL,
	[CustomDimensionID] [nvarchar](1024) NULL,
	[CustomProcedure] [nvarchar](1024) NULL,
	[ProcessOrder] [int] NOT NULL,
	[IsDisabled] [bit] NOT NULL,
 CONSTRAINT [PK_IncUpdate_EventConfiguration_Process] PRIMARY KEY CLUSTERED 
(
	[EventID] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [app].[IncUpdate_EventConfiguration_Process] ADD  CONSTRAINT [DF_IncUpdate_EventConfiguration_Process_ProcessOrder]  DEFAULT ((10)) FOR [ProcessOrder]
GO
ALTER TABLE [app].[IncUpdate_EventConfiguration_Process] ADD  CONSTRAINT [DF_IncUpdate_EventConfiguration_Process_IsDisabled]  DEFAULT ((0)) FOR [IsDisabled]
GO
ALTER TABLE [app].[IncUpdate_EventConfiguration_Process]  WITH CHECK ADD  CONSTRAINT [FK_IncUpdate_EventConfiguration_Process_IncUpdate_EventConfiguration] FOREIGN KEY([EventID])
REFERENCES [app].[IncUpdate_EventConfiguration] ([EventID])
GO
ALTER TABLE [app].[IncUpdate_EventConfiguration_Process] CHECK CONSTRAINT [FK_IncUpdate_EventConfiguration_Process_IncUpdate_EventConfiguration]
GO
