SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpgradeJob](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RunTypeID] [int] NOT NULL,
	[CurrentVersion] [nvarchar](30) NOT NULL,
	[InstallVersion] [nvarchar](30) NOT NULL,
	[StatusID] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[Duration] [int] NULL,
	[MaintenanceID] [int] NULL,
	[ScheduledAt] [datetime] NULL,
	[IsHandled] [bit] NOT NULL,
 CONSTRAINT [PK_UpgradeJob] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UpgradeJob] ADD  CONSTRAINT [DF_UpgradeJob_IsHandled]  DEFAULT ((0)) FOR [IsHandled]
GO
ALTER TABLE [dbo].[UpgradeJob]  WITH CHECK ADD  CONSTRAINT [FK_UpgradeJob_MaintenanceLog] FOREIGN KEY([MaintenanceID])
REFERENCES [dbo].[MaintenanceLog] ([ID])
GO
ALTER TABLE [dbo].[UpgradeJob] CHECK CONSTRAINT [FK_UpgradeJob_MaintenanceLog]
GO
ALTER TABLE [dbo].[UpgradeJob]  WITH CHECK ADD  CONSTRAINT [FK_UpgradeJob_UpgradeRunType] FOREIGN KEY([RunTypeID])
REFERENCES [dbo].[UpgradeRunType] ([ID])
GO
ALTER TABLE [dbo].[UpgradeJob] CHECK CONSTRAINT [FK_UpgradeJob_UpgradeRunType]
GO
ALTER TABLE [dbo].[UpgradeJob]  WITH CHECK ADD  CONSTRAINT [FK_UpgradeJob_UpgradeStatus] FOREIGN KEY([StatusID])
REFERENCES [dbo].[UpgradeStatus] ([ID])
GO
ALTER TABLE [dbo].[UpgradeJob] CHECK CONSTRAINT [FK_UpgradeJob_UpgradeStatus]
GO
ALTER TABLE [dbo].[UpgradeJob]  WITH CHECK ADD  CONSTRAINT [FK_UpgradeJob_UserSecurityGroup] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UpgradeJob] CHECK CONSTRAINT [FK_UpgradeJob_UserSecurityGroup]
GO
