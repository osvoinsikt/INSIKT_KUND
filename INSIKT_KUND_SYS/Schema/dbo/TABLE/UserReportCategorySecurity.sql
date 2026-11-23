SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserReportCategorySecurity](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[GroupID] [int] NULL,
	[CategoryID] [int] NULL,
	[ReportID] [int] NULL,
	[Read] [bit] NOT NULL,
	[Write] [bit] NOT NULL,
 CONSTRAINT [PK_UserReportCategorySecurity] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserReportCategorySecurity]  WITH CHECK ADD  CONSTRAINT [FK_UserReportCategorySecurity_Category] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Category] ([ID])
GO
ALTER TABLE [dbo].[UserReportCategorySecurity] CHECK CONSTRAINT [FK_UserReportCategorySecurity_Category]
GO
ALTER TABLE [dbo].[UserReportCategorySecurity]  WITH CHECK ADD  CONSTRAINT [FK_UserReportCategorySecurity_Group] FOREIGN KEY([GroupID])
REFERENCES [dbo].[Group] ([ID])
GO
ALTER TABLE [dbo].[UserReportCategorySecurity] CHECK CONSTRAINT [FK_UserReportCategorySecurity_Group]
GO
ALTER TABLE [dbo].[UserReportCategorySecurity]  WITH CHECK ADD  CONSTRAINT [FK_UserReportCategorySecurity_Report] FOREIGN KEY([ReportID])
REFERENCES [dbo].[Report] ([ID])
GO
ALTER TABLE [dbo].[UserReportCategorySecurity] CHECK CONSTRAINT [FK_UserReportCategorySecurity_Report]
GO
ALTER TABLE [dbo].[UserReportCategorySecurity]  WITH CHECK ADD  CONSTRAINT [FK_UserReportCategorySecurity_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserReportCategorySecurity] CHECK CONSTRAINT [FK_UserReportCategorySecurity_UserSecurityGroup]
GO
