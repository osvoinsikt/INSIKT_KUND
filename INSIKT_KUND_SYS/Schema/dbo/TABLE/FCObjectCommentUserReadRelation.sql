SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectCommentUserReadRelation](
	[FCObjectCommentID] [int] NOT NULL,
	[ReadBy] [int] NOT NULL,
	[ReadDate] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo_FCObjectCommentUserReadRelation] PRIMARY KEY CLUSTERED 
(
	[FCObjectCommentID] ASC,
	[ReadBy] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCObjectCommentUserReadRelation]  WITH CHECK ADD  CONSTRAINT [FK_dbo_FCObjectCommentUserReadRelation_FCObjectCommentID] FOREIGN KEY([FCObjectCommentID])
REFERENCES [dbo].[FCObjectComment] ([ID])
GO
ALTER TABLE [dbo].[FCObjectCommentUserReadRelation] CHECK CONSTRAINT [FK_dbo_FCObjectCommentUserReadRelation_FCObjectCommentID]
GO
ALTER TABLE [dbo].[FCObjectCommentUserReadRelation]  WITH CHECK ADD  CONSTRAINT [FK_dbo_FCObjectCommentUserReadRelation_ReadBy] FOREIGN KEY([ReadBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCObjectCommentUserReadRelation] CHECK CONSTRAINT [FK_dbo_FCObjectCommentUserReadRelation_ReadBy]
GO
