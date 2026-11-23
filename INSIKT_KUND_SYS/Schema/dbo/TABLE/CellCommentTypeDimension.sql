SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CellCommentTypeDimension](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CellCommentTypeID] [int] NOT NULL,
	[DimensionName] [nvarchar](200) NOT NULL,
	[HierarchyName] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_CellCommentTypeDimension] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[CellCommentTypeDimension]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentTypeDimension_CellCommentType] FOREIGN KEY([CellCommentTypeID])
REFERENCES [dbo].[CellCommentType] ([ID])
GO
ALTER TABLE [dbo].[CellCommentTypeDimension] CHECK CONSTRAINT [FK_CellCommentTypeDimension_CellCommentType]
GO
