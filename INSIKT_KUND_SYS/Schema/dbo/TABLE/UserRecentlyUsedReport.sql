SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRecentlyUsedReport](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[ReportID] [int] NOT NULL,
	[OpenedDate] [datetime] NOT NULL,
	[RunningAsUserID] [int] NULL,
	[ReportSnapshotID] [int] NULL,
	[ReportRevisionNr] [int] NULL,
 CONSTRAINT [PK_UserLastUsedReports] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_UserRecentlyUsedReport_UserID_OpenedDate] ON [dbo].[UserRecentlyUsedReport]
(
	[UserID] ASC,
	[OpenedDate] ASC
)
INCLUDE([ReportID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserRecentlyUsedReport]  WITH CHECK ADD  CONSTRAINT [FK_UserRecentlyUsedReport_Report] FOREIGN KEY([ReportID])
REFERENCES [dbo].[Report] ([ID])
GO
ALTER TABLE [dbo].[UserRecentlyUsedReport] CHECK CONSTRAINT [FK_UserRecentlyUsedReport_Report]
GO
ALTER TABLE [dbo].[UserRecentlyUsedReport]  WITH CHECK ADD  CONSTRAINT [FK_UserRecentlyUsedReport_ReportSnapshot] FOREIGN KEY([ReportSnapshotID])
REFERENCES [dbo].[ReportSnapshot] ([ID])
GO
ALTER TABLE [dbo].[UserRecentlyUsedReport] CHECK CONSTRAINT [FK_UserRecentlyUsedReport_ReportSnapshot]
GO
ALTER TABLE [dbo].[UserRecentlyUsedReport]  WITH CHECK ADD  CONSTRAINT [FK_UserRecentlyUsedReport_RunningAsUser] FOREIGN KEY([RunningAsUserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserRecentlyUsedReport] CHECK CONSTRAINT [FK_UserRecentlyUsedReport_RunningAsUser]
GO
ALTER TABLE [dbo].[UserRecentlyUsedReport]  WITH CHECK ADD  CONSTRAINT [FK_UserRecentlyUsedReport_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserRecentlyUsedReport] CHECK CONSTRAINT [FK_UserRecentlyUsedReport_UserSecurityGroup]
GO
