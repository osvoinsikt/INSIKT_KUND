SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[HierarchyNodeLanguage](
	[HierarchyNodeID] [int] NOT NULL,
	[LanguageID] [int] NOT NULL,
	[LangExpression] [nvarchar](1000) NULL,
 CONSTRAINT [PK_HierarchyNodeLanguage] PRIMARY KEY CLUSTERED 
(
	[HierarchyNodeID] ASC,
	[LanguageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [app].[HierarchyNodeLanguage]  WITH CHECK ADD  CONSTRAINT [FK_HierarchyNodeLanguage_HierarchyNode] FOREIGN KEY([HierarchyNodeID])
REFERENCES [app].[HierarchyNode] ([HierarchyNodeID])
GO
ALTER TABLE [app].[HierarchyNodeLanguage] CHECK CONSTRAINT [FK_HierarchyNodeLanguage_HierarchyNode]
GO
ALTER TABLE [app].[HierarchyNodeLanguage]  WITH CHECK ADD  CONSTRAINT [FK_HierarchyNodeLanguage_Language] FOREIGN KEY([LanguageID])
REFERENCES [app].[Language] ([LanguageID])
GO
ALTER TABLE [app].[HierarchyNodeLanguage] CHECK CONSTRAINT [FK_HierarchyNodeLanguage_Language]
GO
