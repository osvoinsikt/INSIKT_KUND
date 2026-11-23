SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCProjectCalcReviseReason](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCVersionCategoryID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](255) NULL,
	[CommentAllowed] [bit] NOT NULL,
	[CommentRequired] [bit] NOT NULL,
	[SortOrder] [int] NULL,
	[IsDefault] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectCalcReviseReason] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCProjectCalcReviseReason]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcReviseReason_FCVersionCategory] FOREIGN KEY([FCVersionCategoryID])
REFERENCES [dbo].[FCVersionCategory] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcReviseReason] CHECK CONSTRAINT [FK_FCProjectCalcReviseReason_FCVersionCategory]
GO
