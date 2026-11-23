SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSourcePerspectiveMemberSelectionRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourcePerspectiveID] [int] NOT NULL,
	[DataSourceDimensionHierarchyID] [int] NOT NULL,
	[MemberUniqueName] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_DataSourcePerspectiveMemberSelectionRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataSourcePerspectiveMemberSelectionRelation]  WITH CHECK ADD  CONSTRAINT [FK_DataSourcePerspectiveMemberSelectionRelation_Hierarchy] FOREIGN KEY([DataSourceDimensionHierarchyID])
REFERENCES [dbo].[DataSourceDimensionHierarchy] ([ID])
GO
ALTER TABLE [dbo].[DataSourcePerspectiveMemberSelectionRelation] CHECK CONSTRAINT [FK_DataSourcePerspectiveMemberSelectionRelation_Hierarchy]
GO
ALTER TABLE [dbo].[DataSourcePerspectiveMemberSelectionRelation]  WITH CHECK ADD  CONSTRAINT [FK_DataSourcePerspectiveMemberSelectionRelation_Perspective] FOREIGN KEY([DataSourcePerspectiveID])
REFERENCES [dbo].[DataSourcePerspective] ([ID])
GO
ALTER TABLE [dbo].[DataSourcePerspectiveMemberSelectionRelation] CHECK CONSTRAINT [FK_DataSourcePerspectiveMemberSelectionRelation_Perspective]
GO
