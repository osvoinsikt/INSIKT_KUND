SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportSnapshotSchedule](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Comment] [nvarchar](max) NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[ScheduleID] [int] NOT NULL,
 CONSTRAINT [PK_ReportSnapshotSchedule] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[ReportSnapshotSchedule]  WITH CHECK ADD  CONSTRAINT [FK_ReportSnapshotSchedule_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[ReportSnapshotSchedule] CHECK CONSTRAINT [FK_ReportSnapshotSchedule_CreatedBy]
GO
ALTER TABLE [dbo].[ReportSnapshotSchedule]  WITH CHECK ADD  CONSTRAINT [FK_ReportSnapshotSchedule_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[ReportSnapshotSchedule] CHECK CONSTRAINT [FK_ReportSnapshotSchedule_ModifiedBy]
GO
ALTER TABLE [dbo].[ReportSnapshotSchedule]  WITH CHECK ADD  CONSTRAINT [FK_ReportSnapshotSchedule_Schedule] FOREIGN KEY([ScheduleID])
REFERENCES [dbo].[Schedule] ([ID])
GO
ALTER TABLE [dbo].[ReportSnapshotSchedule] CHECK CONSTRAINT [FK_ReportSnapshotSchedule_Schedule]
GO
