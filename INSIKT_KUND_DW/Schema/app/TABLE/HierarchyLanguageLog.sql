SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[HierarchyLanguageLog](
	[HierarchyLogID] [int] NOT NULL,
	[HierarchyID] [int] NOT NULL,
	[LanguageID] [int] NOT NULL,
	[Caption] [nvarchar](150) NULL,
 CONSTRAINT [PK_HierarchyLanguageLog] PRIMARY KEY CLUSTERED 
(
	[HierarchyLogID] ASC,
	[HierarchyID] ASC,
	[LanguageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [app].[HierarchyLanguageLog]  WITH CHECK ADD  CONSTRAINT [FK_HierarchyLanguageLog_HierarchyLog] FOREIGN KEY([HierarchyLogID], [HierarchyID])
REFERENCES [app].[HierarchyLog] ([HierarchyLogID], [HierarchyID])
GO
ALTER TABLE [app].[HierarchyLanguageLog] CHECK CONSTRAINT [FK_HierarchyLanguageLog_HierarchyLog]
GO
ALTER TABLE [app].[HierarchyLanguageLog]  WITH CHECK ADD  CONSTRAINT [FK_HierarchyLanguageLog_Language] FOREIGN KEY([LanguageID])
REFERENCES [app].[Language] ([LanguageID])
GO
ALTER TABLE [app].[HierarchyLanguageLog] CHECK CONSTRAINT [FK_HierarchyLanguageLog_Language]
GO
