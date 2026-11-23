SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserHierarchyRelationSet](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DimensionHierarchyID] [int] NOT NULL,
	[Caption] [varchar](250) NOT NULL,
	[EnableUseInDimensionReplacement] [bit] NOT NULL,
 CONSTRAINT [PK_UserHierarchyRelationSet] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[UserHierarchyRelationSet] ADD  CONSTRAINT [DF_UserHierarchyRelationSet_EnableUseInDimensionReplacement]  DEFAULT ((0)) FOR [EnableUseInDimensionReplacement]
GO
ALTER TABLE [dbo].[UserHierarchyRelationSet]  WITH CHECK ADD  CONSTRAINT [FK_UserHierarchyRelationSet_DataSourceDimensionHierarchy] FOREIGN KEY([DimensionHierarchyID])
REFERENCES [dbo].[DataSourceDimensionHierarchy] ([ID])
GO
ALTER TABLE [dbo].[UserHierarchyRelationSet] CHECK CONSTRAINT [FK_UserHierarchyRelationSet_DataSourceDimensionHierarchy]
GO
