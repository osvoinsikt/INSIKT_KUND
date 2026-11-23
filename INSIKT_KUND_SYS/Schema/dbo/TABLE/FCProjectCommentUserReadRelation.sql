SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectCommentUserReadRelation](
	[FCProjectCommentID] [int] NOT NULL,
	[ReadBy] [int] NOT NULL,
	[ReadDate] [datetime] NOT NULL,
 CONSTRAINT [PK_FCProjectCommentUserReadRelation] PRIMARY KEY CLUSTERED 
(
	[FCProjectCommentID] ASC,
	[ReadBy] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectCommentUserReadRelation] ADD  CONSTRAINT [DF_FCProjectCommentUserReadRelation_ReadDate]  DEFAULT (getutcdate()) FOR [ReadDate]
GO
ALTER TABLE [dbo].[FCProjectCommentUserReadRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCommentUserReadRelation_FCProjectComment] FOREIGN KEY([FCProjectCommentID])
REFERENCES [dbo].[FCProjectComment] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCommentUserReadRelation] CHECK CONSTRAINT [FK_FCProjectCommentUserReadRelation_FCProjectComment]
GO
ALTER TABLE [dbo].[FCProjectCommentUserReadRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCommentUserReadRelation_UserSecurityGroup] FOREIGN KEY([ReadBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProjectCommentUserReadRelation] CHECK CONSTRAINT [FK_FCProjectCommentUserReadRelation_UserSecurityGroup]
GO
