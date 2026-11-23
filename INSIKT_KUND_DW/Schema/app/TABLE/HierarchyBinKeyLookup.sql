SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[HierarchyBinKeyLookup](
	[HierarchyID] [int] NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BinID] [varbinary](128) NOT NULL,
 CONSTRAINT [PK_app_DimEngine_HierarchyBinKeyLookup] PRIMARY KEY CLUSTERED 
(
	[HierarchyID] ASC,
	[BinID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [app].[HierarchyBinKeyLookup]  WITH CHECK ADD  CONSTRAINT [FK_HierarchyBinKeyLookup_Hierarchy] FOREIGN KEY([HierarchyID])
REFERENCES [app].[Hierarchy] ([HierarchyID])
GO
ALTER TABLE [app].[HierarchyBinKeyLookup] CHECK CONSTRAINT [FK_HierarchyBinKeyLookup_Hierarchy]
GO
