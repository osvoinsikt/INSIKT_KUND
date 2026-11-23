SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CellCommentValue](
	[CellCommentID] [int] NOT NULL,
	[MultipleChoiceID] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[BitValue] [bit] NULL,
	[DateValue] [datetime] NULL,
	[TextValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_CellCommentValueRelation] PRIMARY KEY CLUSTERED 
(
	[CellCommentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[CellCommentValue]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentValueRelation_CellComment] FOREIGN KEY([CellCommentID])
REFERENCES [dbo].[CellComment] ([ID])
GO
ALTER TABLE [dbo].[CellCommentValue] CHECK CONSTRAINT [FK_CellCommentValueRelation_CellComment]
GO
ALTER TABLE [dbo].[CellCommentValue]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentValueRelation_CreatedByUser] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[CellCommentValue] CHECK CONSTRAINT [FK_CellCommentValueRelation_CreatedByUser]
GO
ALTER TABLE [dbo].[CellCommentValue]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentValueRelation_MultipleChoice] FOREIGN KEY([MultipleChoiceID])
REFERENCES [dbo].[MultipleChoice] ([ID])
GO
ALTER TABLE [dbo].[CellCommentValue] CHECK CONSTRAINT [FK_CellCommentValueRelation_MultipleChoice]
GO
