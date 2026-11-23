SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [sa].[base_SourceSystem](
	[SA_SourceSystemID] [int] NOT NULL,
	[Description] [varchar](500) NULL,
	[LinkedServer] [sysname] NULL,
	[Database] [sysname] NULL,
	[TablePrefix] [sysname] NULL,
	[TargetSchema] [nvarchar](50) NULL,
	[CompanyCode] [nvarchar](50) NULL,
	[SourceSystemProviderID] [int] NOT NULL,
 CONSTRAINT [PK__base_Com__2F4120BF39B2C154] PRIMARY KEY CLUSTERED 
(
	[SA_SourceSystemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [sa].[base_SourceSystem] ADD  DEFAULT ((1)) FOR [SourceSystemProviderID]
GO
ALTER TABLE [sa].[base_SourceSystem]  WITH CHECK ADD  CONSTRAINT [FK_base_SourceSystem_base_SourceSystemProvider] FOREIGN KEY([SourceSystemProviderID])
REFERENCES [sa].[SourceSystemProvider] ([SourceSystemProviderID])
GO
ALTER TABLE [sa].[base_SourceSystem] CHECK CONSTRAINT [FK_base_SourceSystem_base_SourceSystemProvider]
GO
