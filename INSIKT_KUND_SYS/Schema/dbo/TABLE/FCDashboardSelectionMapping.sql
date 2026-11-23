SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCDashboardSelectionMapping](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceDashboardPresentationObjectID] [int] NULL,
	[SourceDataSourceHierarchyID] [int] NULL,
	[SourceFCObjectPropertyID] [int] NULL,
	[TargetDashboardPresentationObjectID] [int] NOT NULL,
	[TargetDataSourceHierarchyID] [int] NULL,
	[TargetFCObjectPropertyID] [int] NULL,
	[DataSourceDimensionHierarchySelectionGeneratorID] [int] NULL,
	[IsEnabled] [bit] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[IsHierarchyTreeFilter] [bit] NOT NULL,
 CONSTRAINT [PK_FCDashboardSelectionMapping] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping] ADD  CONSTRAINT [DF_FCDashboardSelectionMapping_Enable]  DEFAULT ((1)) FOR [IsEnabled]
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping] ADD  CONSTRAINT [DF_FCDashboardSelectionMapping_IsHierarchyTreeFilter]  DEFAULT ((0)) FOR [IsHierarchyTreeFilter]
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping]  WITH CHECK ADD  CONSTRAINT [FK_FCDashboardSelectionMapping_SelectionGenerator] FOREIGN KEY([DataSourceDimensionHierarchySelectionGeneratorID])
REFERENCES [dbo].[DataSourceDimensionHierarchySelectionGenerator] ([ID])
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping] CHECK CONSTRAINT [FK_FCDashboardSelectionMapping_SelectionGenerator]
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping]  WITH CHECK ADD  CONSTRAINT [FK_FCDashboardSelectionMapping_SourceFCObjectProperty] FOREIGN KEY([SourceFCObjectPropertyID])
REFERENCES [dbo].[FCObjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping] CHECK CONSTRAINT [FK_FCDashboardSelectionMapping_SourceFCObjectProperty]
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping]  WITH CHECK ADD  CONSTRAINT [FK_FCDashboardSelectionMapping_SourceHierarchy] FOREIGN KEY([SourceDataSourceHierarchyID])
REFERENCES [dbo].[DataSourceDimensionHierarchy] ([ID])
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping] CHECK CONSTRAINT [FK_FCDashboardSelectionMapping_SourceHierarchy]
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping]  WITH CHECK ADD  CONSTRAINT [FK_FCDashboardSelectionMapping_SourcePresentationObject] FOREIGN KEY([SourceDashboardPresentationObjectID])
REFERENCES [dbo].[FCDashboardPresentationObjectRelation] ([ID])
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping] CHECK CONSTRAINT [FK_FCDashboardSelectionMapping_SourcePresentationObject]
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping]  WITH CHECK ADD  CONSTRAINT [FK_FCDashboardSelectionMapping_TargetFCObjectProperty] FOREIGN KEY([TargetFCObjectPropertyID])
REFERENCES [dbo].[FCObjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping] CHECK CONSTRAINT [FK_FCDashboardSelectionMapping_TargetFCObjectProperty]
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping]  WITH CHECK ADD  CONSTRAINT [FK_FCDashboardSelectionMapping_TargetHierarchy] FOREIGN KEY([TargetDataSourceHierarchyID])
REFERENCES [dbo].[DataSourceDimensionHierarchy] ([ID])
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping] CHECK CONSTRAINT [FK_FCDashboardSelectionMapping_TargetHierarchy]
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping]  WITH CHECK ADD  CONSTRAINT [FK_FCDashboardSelectionMapping_TargetPresentationObject] FOREIGN KEY([TargetDashboardPresentationObjectID])
REFERENCES [dbo].[FCDashboardPresentationObjectRelation] ([ID])
GO
ALTER TABLE [dbo].[FCDashboardSelectionMapping] CHECK CONSTRAINT [FK_FCDashboardSelectionMapping_TargetPresentationObject]
GO
