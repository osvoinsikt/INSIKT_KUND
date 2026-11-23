SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataSources](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[SourceCube] [nvarchar](50) NULL,
	[MainTimeDim] [varchar](50) NULL,
	[DTDQuery] [nvarchar](max) NULL,
	[DWServer] [varchar](50) NULL,
	[DWDatabase] [varchar](50) NULL,
	[AdminUser] [varchar](150) NULL,
	[AdminPassword] [varchar](500) NULL,
	[AllowDynamicFilter] [bit] NULL,
	[DynamicFilterDefault] [bit] NULL,
	[ReverseYearsInTimeDims] [bit] NULL,
	[DTDMethodID] [int] NOT NULL,
	[OrderDimensionsAlphabetically] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[AvailableInAnalysis] [bit] NOT NULL,
	[DataSourceConnectionID] [int] NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[EnableAIUse] [bit] NOT NULL,
 CONSTRAINT [PK_DataSources] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[DataSources] ADD  CONSTRAINT [DF_DataSources_DrillthroughMethod]  DEFAULT ((1)) FOR [DTDMethodID]
GO
ALTER TABLE [dbo].[DataSources] ADD  CONSTRAINT [DF_DataSources_OrderDimensionsAlphabetically]  DEFAULT ((1)) FOR [OrderDimensionsAlphabetically]
GO
ALTER TABLE [dbo].[DataSources] ADD  CONSTRAINT [DF_DataSources_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[DataSources] ADD  CONSTRAINT [DF_DataSources_AvailableInAnalysis]  DEFAULT ((0)) FOR [AvailableInAnalysis]
GO
ALTER TABLE [dbo].[DataSources] ADD  CONSTRAINT [DF_DataSources_IsDefault]  DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[DataSources] ADD  CONSTRAINT [DF_DataSources_EnableAIUse]  DEFAULT ((0)) FOR [EnableAIUse]
GO
ALTER TABLE [dbo].[DataSources]  WITH CHECK ADD  CONSTRAINT [FK_DataSources_DataSourceConnection] FOREIGN KEY([DataSourceConnectionID])
REFERENCES [dbo].[DataSourceConnection] ([ID])
GO
ALTER TABLE [dbo].[DataSources] CHECK CONSTRAINT [FK_DataSources_DataSourceConnection]
GO
ALTER TABLE [dbo].[DataSources]  WITH CHECK ADD  CONSTRAINT [FK_DataSources_DrillthroughMethod] FOREIGN KEY([DTDMethodID])
REFERENCES [dbo].[DrillthroughMethod] ([ID])
GO
ALTER TABLE [dbo].[DataSources] CHECK CONSTRAINT [FK_DataSources_DrillthroughMethod]
GO
