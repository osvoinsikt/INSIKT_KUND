SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[DbSchemaLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DateTime] [datetime] NOT NULL,
	[EventType] [nvarchar](128) NULL,
	[SchemaName] [nvarchar](128) NULL,
	[ObjectType] [nvarchar](128) NULL,
	[ObjectName] [nvarchar](128) NULL,
	[TargetObjectName] [nvarchar](128) NULL,
	[TargetObjectType] [nvarchar](128) NULL,
	[TargetObjectDefinition] [nvarchar](max) NULL,
	[DbSchemaLogBatchID] [int] NULL,
	[EventData] [xml] NULL,
 CONSTRAINT [PK_DbSchemaLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [app].[DbSchemaLog] ADD  CONSTRAINT [DF_DatabaseLogs_DateTime]  DEFAULT (getutcdate()) FOR [DateTime]
GO
