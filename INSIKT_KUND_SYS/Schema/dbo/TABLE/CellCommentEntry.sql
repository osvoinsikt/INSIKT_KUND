SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CellCommentEntry](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CellCommentID] [int] NOT NULL,
	[Comment] [nvarchar](max) NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
	[IsReadOnly] [bit] NOT NULL,
 CONSTRAINT [PK_CellCommentEntry] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_CellCommentEntry_CellCommentID] ON [dbo].[CellCommentEntry]
(
	[CellCommentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CellCommentEntry] ADD  CONSTRAINT [DF_CellCommentEntry_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[CellCommentEntry] ADD  CONSTRAINT [DF_CellCommentEntry_IsReadOnly]  DEFAULT ((0)) FOR [IsReadOnly]
GO
ALTER TABLE [dbo].[CellCommentEntry]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentEntry_CellComment] FOREIGN KEY([CellCommentID])
REFERENCES [dbo].[CellComment] ([ID])
GO
ALTER TABLE [dbo].[CellCommentEntry] CHECK CONSTRAINT [FK_CellCommentEntry_CellComment]
GO
ALTER TABLE [dbo].[CellCommentEntry]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentEntry_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[CellCommentEntry] CHECK CONSTRAINT [FK_CellCommentEntry_CreatedBy]
GO
