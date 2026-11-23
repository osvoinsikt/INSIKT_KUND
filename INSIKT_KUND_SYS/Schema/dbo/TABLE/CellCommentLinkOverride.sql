SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CellCommentLinkOverride](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CellCommentLinkID] [int] NOT NULL,
	[DimensionName] [nvarchar](50) NOT NULL,
	[UniqueName] [nvarchar](300) NULL,
	[ElementKey] [nvarchar](100) NULL,
 CONSTRAINT [PK_CellCommentLinkOverride] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[CellCommentLinkOverride]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentLinkOverride_CellCommentLink] FOREIGN KEY([CellCommentLinkID])
REFERENCES [dbo].[CellCommentLink] ([ID])
GO
ALTER TABLE [dbo].[CellCommentLinkOverride] CHECK CONSTRAINT [FK_CellCommentLinkOverride_CellCommentLink]
GO
