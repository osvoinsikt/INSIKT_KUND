SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSourceDimensionHierarchySelectionGenerator](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceDataSourceDimensionHierarchyID] [int] NULL,
	[TargetDataSourceDimensionHierarchyID] [int] NOT NULL,
	[SelectionGeneratingMeasure] [nvarchar](100) NOT NULL,
	[IsTwoWay] [bit] NOT NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_DataSourceDimensionHierarchySelectionGenerator] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataSourceDimensionHierarchySelectionGenerator]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceDimensionHierarchySelectionGenerator_SourceHierarchy] FOREIGN KEY([SourceDataSourceDimensionHierarchyID])
REFERENCES [dbo].[DataSourceDimensionHierarchy] ([ID])
GO
ALTER TABLE [dbo].[DataSourceDimensionHierarchySelectionGenerator] CHECK CONSTRAINT [FK_DataSourceDimensionHierarchySelectionGenerator_SourceHierarchy]
GO
ALTER TABLE [dbo].[DataSourceDimensionHierarchySelectionGenerator]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceDimensionHierarchySelectionGenerator_TargetHierarchy] FOREIGN KEY([TargetDataSourceDimensionHierarchyID])
REFERENCES [dbo].[DataSourceDimensionHierarchy] ([ID])
GO
ALTER TABLE [dbo].[DataSourceDimensionHierarchySelectionGenerator] CHECK CONSTRAINT [FK_DataSourceDimensionHierarchySelectionGenerator_TargetHierarchy]
GO
