SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [insikt].[CopiedComments](
	[SourceCellCommentID] [int] NULL,
	[TargetCellCommentID] [int] NULL,
	[CopyType] [nvarchar](30) NULL
) ON [PRIMARY]

GO
