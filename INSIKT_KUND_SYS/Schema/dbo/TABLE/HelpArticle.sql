SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HelpArticle](
	[ControlName] [nvarchar](100) NOT NULL,
	[ParentControlName] [nvarchar](100) NULL,
	[SortOrder] [int] NOT NULL,
	[IsSystemArticle] [bit] NOT NULL,
 CONSTRAINT [PK_HelpArticle] PRIMARY KEY CLUSTERED 
(
	[ControlName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[HelpArticle]  WITH CHECK ADD  CONSTRAINT [FK_HelpArticle_ParentControlName] FOREIGN KEY([ParentControlName])
REFERENCES [dbo].[HelpArticle] ([ControlName])
GO
ALTER TABLE [dbo].[HelpArticle] CHECK CONSTRAINT [FK_HelpArticle_ParentControlName]
GO
