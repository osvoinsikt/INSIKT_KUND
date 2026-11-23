SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserReportCategorySecurityLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InitiatedBy] [int] NOT NULL,
	[RunningAsUserID] [int] NULL,
	[EventDate] [datetime] NOT NULL,
	[TypeID] [int] NOT NULL,
	[UserID] [int] NULL,
	[GroupID] [int] NULL,
	[CategoryID] [int] NULL,
	[ReportID] [int] NULL,
	[ReadAccess] [bit] NULL,
	[WriteAccess] [bit] NULL,
	[NewCategoryID] [int] NULL,
 CONSTRAINT [PK_UserReportCategorySecurityLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog]  WITH CHECK ADD  CONSTRAINT [FK_UserReportCategorySecurityLog_Category] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Category] ([ID])
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog] CHECK CONSTRAINT [FK_UserReportCategorySecurityLog_Category]
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog]  WITH CHECK ADD  CONSTRAINT [FK_UserReportCategorySecurityLog_Group] FOREIGN KEY([GroupID])
REFERENCES [dbo].[Group] ([ID])
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog] CHECK CONSTRAINT [FK_UserReportCategorySecurityLog_Group]
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog]  WITH CHECK ADD  CONSTRAINT [FK_UserReportCategorySecurityLog_InitiatedBy] FOREIGN KEY([InitiatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog] CHECK CONSTRAINT [FK_UserReportCategorySecurityLog_InitiatedBy]
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog]  WITH CHECK ADD  CONSTRAINT [FK_UserReportCategorySecurityLog_NewCategory] FOREIGN KEY([NewCategoryID])
REFERENCES [dbo].[Category] ([ID])
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog] CHECK CONSTRAINT [FK_UserReportCategorySecurityLog_NewCategory]
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog]  WITH CHECK ADD  CONSTRAINT [FK_UserReportCategorySecurityLog_Report] FOREIGN KEY([ReportID])
REFERENCES [dbo].[Report] ([ID])
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog] CHECK CONSTRAINT [FK_UserReportCategorySecurityLog_Report]
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog]  WITH CHECK ADD  CONSTRAINT [FK_UserReportCategorySecurityLog_RunningAsUser] FOREIGN KEY([RunningAsUserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog] CHECK CONSTRAINT [FK_UserReportCategorySecurityLog_RunningAsUser]
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog]  WITH CHECK ADD  CONSTRAINT [FK_UserReportCategorySecurityLog_Type] FOREIGN KEY([TypeID])
REFERENCES [dbo].[UserReportCategorySecurityLogType] ([ID])
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog] CHECK CONSTRAINT [FK_UserReportCategorySecurityLog_Type]
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog]  WITH CHECK ADD  CONSTRAINT [FK_UserReportCategorySecurityLog_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserReportCategorySecurityLog] CHECK CONSTRAINT [FK_UserReportCategorySecurityLog_User]
GO
