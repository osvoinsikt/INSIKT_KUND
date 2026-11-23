SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [process].[ProcessCommentUserReadRelation](
	[ProcessCommentID] [int] NOT NULL,
	[ReadBy] [int] NOT NULL,
	[ReadDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ProcessCommentUserReadRelation] PRIMARY KEY CLUSTERED 
(
	[ProcessCommentID] ASC,
	[ReadBy] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [process].[ProcessCommentUserReadRelation]  WITH CHECK ADD  CONSTRAINT [FK_ProcessCommentUserReadRelation_ProcessComment] FOREIGN KEY([ProcessCommentID])
REFERENCES [process].[ProcessComment] ([ID])
GO
ALTER TABLE [process].[ProcessCommentUserReadRelation] CHECK CONSTRAINT [FK_ProcessCommentUserReadRelation_ProcessComment]
GO
