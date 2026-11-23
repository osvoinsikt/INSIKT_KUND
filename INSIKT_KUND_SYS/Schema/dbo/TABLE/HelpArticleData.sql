SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HelpArticleData](
	[ControlName] [nvarchar](100) NOT NULL,
	[LangID] [int] NOT NULL,
	[Title] [nvarchar](max) NULL,
	[Data] [nvarchar](max) NULL,
 CONSTRAINT [PK_HelpArticleData] PRIMARY KEY CLUSTERED 
(
	[ControlName] ASC,
	[LangID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[HelpArticleData]  WITH CHECK ADD  CONSTRAINT [FK_HelpArticleData_ControlName] FOREIGN KEY([ControlName])
REFERENCES [dbo].[HelpArticle] ([ControlName])
GO
ALTER TABLE [dbo].[HelpArticleData] CHECK CONSTRAINT [FK_HelpArticleData_ControlName]
GO
ALTER TABLE [dbo].[HelpArticleData]  WITH CHECK ADD  CONSTRAINT [FK_HelpArticleData_Language] FOREIGN KEY([LangID])
REFERENCES [dbo].[Language] ([ID])
GO
ALTER TABLE [dbo].[HelpArticleData] CHECK CONSTRAINT [FK_HelpArticleData_Language]
GO
