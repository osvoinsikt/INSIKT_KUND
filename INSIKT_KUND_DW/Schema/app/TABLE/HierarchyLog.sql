SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[HierarchyLog](
	[HierarchyLogID] [int] NOT NULL,
	[HierarchyID] [int] NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[Caption] [nvarchar](150) NULL,
	[Description] [nvarchar](500) NULL,
 CONSTRAINT [PK_app_HierarchyLog] PRIMARY KEY CLUSTERED 
(
	[HierarchyLogID] ASC,
	[HierarchyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [app].[HierarchyLog]  WITH CHECK ADD  CONSTRAINT [FK_dw_HierarchyLog_HierarchyLogInfo] FOREIGN KEY([HierarchyLogID])
REFERENCES [app].[HierarchyLogInfo] ([HierarchyLogID])
GO
ALTER TABLE [app].[HierarchyLog] CHECK CONSTRAINT [FK_dw_HierarchyLog_HierarchyLogInfo]
GO
