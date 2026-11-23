SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CellCommentDimension](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CellCommentID] [int] NOT NULL,
	[DimensionName] [nvarchar](50) NOT NULL,
	[HierarchyName] [nvarchar](50) NULL,
	[FullMemberName] [nvarchar](300) NOT NULL,
	[ElementKey] [nvarchar](100) NULL,
	[CellCommentTypeID] [int] NULL,
 CONSTRAINT [PK_CellCommentDimension] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_CellCommentDimension_CellCommentTypeID] ON [dbo].[CellCommentDimension]
(
	[CellCommentTypeID] ASC
)
INCLUDE([CellCommentID],[DimensionName],[HierarchyName],[FullMemberName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CellCommentDimension_CommentID] ON [dbo].[CellCommentDimension]
(
	[CellCommentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_CellCommentDimension_CommentIDWithKeyAndName] ON [dbo].[CellCommentDimension]
(
	[CellCommentID] ASC,
	[DimensionName] ASC,
	[ElementKey] ASC
)
INCLUDE([ID],[FullMemberName],[HierarchyName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_CellCommentDimension_DimensionAndMember] ON [dbo].[CellCommentDimension]
(
	[DimensionName] ASC,
	[ElementKey] ASC
)
INCLUDE([HierarchyName],[FullMemberName],[CellCommentID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CellCommentDimension]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentDimension_CellComment] FOREIGN KEY([CellCommentID])
REFERENCES [dbo].[CellComment] ([ID])
GO
ALTER TABLE [dbo].[CellCommentDimension] CHECK CONSTRAINT [FK_CellCommentDimension_CellComment]
GO
ALTER TABLE [dbo].[CellCommentDimension]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentDimension_CellCommentType] FOREIGN KEY([CellCommentTypeID])
REFERENCES [dbo].[CellCommentType] ([ID])
GO
ALTER TABLE [dbo].[CellCommentDimension] CHECK CONSTRAINT [FK_CellCommentDimension_CellCommentType]
GO
