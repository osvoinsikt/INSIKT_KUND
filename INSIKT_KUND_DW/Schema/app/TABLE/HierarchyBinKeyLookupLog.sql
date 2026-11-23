SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[HierarchyBinKeyLookupLog](
	[HierarchyLogID] [int] NOT NULL,
	[HierarchyID] [int] NOT NULL,
	[ID] [int] NOT NULL,
	[BinID] [varbinary](128) NOT NULL,
 CONSTRAINT [PK_app_DimEngine_HierarchyBinKeyLookupLog] PRIMARY KEY CLUSTERED 
(
	[HierarchyLogID] ASC,
	[BinID] ASC,
	[HierarchyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [app].[HierarchyBinKeyLookupLog]  WITH CHECK ADD  CONSTRAINT [FK_dw_HierarchyBinKeyLookupLog_HierarchyLogInfo] FOREIGN KEY([HierarchyLogID])
REFERENCES [app].[HierarchyLogInfo] ([HierarchyLogID])
GO
ALTER TABLE [app].[HierarchyBinKeyLookupLog] CHECK CONSTRAINT [FK_dw_HierarchyBinKeyLookupLog_HierarchyLogInfo]
GO
