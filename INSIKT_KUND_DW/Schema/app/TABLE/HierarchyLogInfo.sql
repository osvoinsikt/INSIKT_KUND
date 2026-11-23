SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[HierarchyLogInfo](
	[HierarchyLogID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](128) NOT NULL,
	[EngineVersion] [varchar](20) NULL,
	[ProcDefinition] [nvarchar](max) NULL,
 CONSTRAINT [PK_app_HierarchyLogInfo] PRIMARY KEY CLUSTERED 
(
	[HierarchyLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [app].[HierarchyLogInfo] ADD  CONSTRAINT [DF_app_HierarchyLogInfo_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [app].[HierarchyLogInfo] ADD  CONSTRAINT [DF_app_HierarchyLogInfo_CreatedBy]  DEFAULT (suser_name()) FOR [CreatedBy]
GO
