SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CellCommentLink](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCColumnID] [int] NOT NULL,
	[FCVersionID] [int] NULL,
	[OverrideWithFCTypeID] [int] NULL,
	[AllowEdit] [bit] NOT NULL,
	[IncludeInExport] [bit] NOT NULL,
 CONSTRAINT [PK_CellCommentLink] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[CellCommentLink] ADD  CONSTRAINT [DK_CellCommentLink_AllowEdit]  DEFAULT ((0)) FOR [AllowEdit]
GO
ALTER TABLE [dbo].[CellCommentLink]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentLink_FCColumn] FOREIGN KEY([FCColumnID])
REFERENCES [dbo].[FCColumns] ([ID])
GO
ALTER TABLE [dbo].[CellCommentLink] CHECK CONSTRAINT [FK_CellCommentLink_FCColumn]
GO
ALTER TABLE [dbo].[CellCommentLink]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentLink_FCVersion] FOREIGN KEY([FCVersionID])
REFERENCES [dbo].[FCVersion] ([ID])
GO
ALTER TABLE [dbo].[CellCommentLink] CHECK CONSTRAINT [FK_CellCommentLink_FCVersion]
GO
ALTER TABLE [dbo].[CellCommentLink]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentLink_OverrideFCType] FOREIGN KEY([OverrideWithFCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[CellCommentLink] CHECK CONSTRAINT [FK_CellCommentLink_OverrideFCType]
GO
