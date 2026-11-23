SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[HierarchyLanguage](
	[HierarchyID] [int] NOT NULL,
	[LanguageID] [int] NOT NULL,
	[Caption] [nvarchar](150) NULL,
 CONSTRAINT [PK_HierarchyLanguage] PRIMARY KEY CLUSTERED 
(
	[HierarchyID] ASC,
	[LanguageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [app].[HierarchyLanguage]  WITH CHECK ADD  CONSTRAINT [FK_HierarchyLanguage_Hierarchy] FOREIGN KEY([HierarchyID])
REFERENCES [app].[Hierarchy] ([HierarchyID])
GO
ALTER TABLE [app].[HierarchyLanguage] CHECK CONSTRAINT [FK_HierarchyLanguage_Hierarchy]
GO
ALTER TABLE [app].[HierarchyLanguage]  WITH CHECK ADD  CONSTRAINT [FK_HierarchyLanguage_Language] FOREIGN KEY([LanguageID])
REFERENCES [app].[Language] ([LanguageID])
GO
ALTER TABLE [app].[HierarchyLanguage] CHECK CONSTRAINT [FK_HierarchyLanguage_Language]
GO
