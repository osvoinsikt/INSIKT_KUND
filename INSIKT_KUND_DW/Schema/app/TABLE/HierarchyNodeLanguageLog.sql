SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[HierarchyNodeLanguageLog](
	[HierarchyLogID] [int] NOT NULL,
	[HierarchyNodeID] [int] NOT NULL,
	[LanguageID] [int] NOT NULL,
	[LangExpression] [nvarchar](1000) NULL,
 CONSTRAINT [PK_HierarchyNode_LanguageLog] PRIMARY KEY CLUSTERED 
(
	[HierarchyLogID] ASC,
	[HierarchyNodeID] ASC,
	[LanguageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [app].[HierarchyNodeLanguageLog]  WITH CHECK ADD  CONSTRAINT [FK_HierarchyNodeLanguageLog_HierarchyNodeLog] FOREIGN KEY([HierarchyLogID], [HierarchyNodeID])
REFERENCES [app].[HierarchyNodeLog] ([HierarchyLogID], [HierarchyNodeID])
GO
ALTER TABLE [app].[HierarchyNodeLanguageLog] CHECK CONSTRAINT [FK_HierarchyNodeLanguageLog_HierarchyNodeLog]
GO
ALTER TABLE [app].[HierarchyNodeLanguageLog]  WITH CHECK ADD  CONSTRAINT [FK_HierarchyNodeLanguageLog_Language] FOREIGN KEY([LanguageID])
REFERENCES [app].[Language] ([LanguageID])
GO
ALTER TABLE [app].[HierarchyNodeLanguageLog] CHECK CONSTRAINT [FK_HierarchyNodeLanguageLog_Language]
GO
