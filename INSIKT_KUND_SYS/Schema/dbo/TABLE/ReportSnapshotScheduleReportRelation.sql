SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportSnapshotScheduleReportRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReportSnapshotScheduleID] [int] NOT NULL,
	[ReportID] [int] NOT NULL,
 CONSTRAINT [PK_ReportSnapshotScheduleReportRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[ReportSnapshotScheduleReportRelation]  WITH CHECK ADD  CONSTRAINT [FK_ReportSnapshotScheduleReportRelation_Report] FOREIGN KEY([ReportID])
REFERENCES [dbo].[Report] ([ID])
GO
ALTER TABLE [dbo].[ReportSnapshotScheduleReportRelation] CHECK CONSTRAINT [FK_ReportSnapshotScheduleReportRelation_Report]
GO
ALTER TABLE [dbo].[ReportSnapshotScheduleReportRelation]  WITH CHECK ADD  CONSTRAINT [FK_ReportSnapshotScheduleReportRelation_ReportSnapshotSubscription] FOREIGN KEY([ReportSnapshotScheduleID])
REFERENCES [dbo].[ReportSnapshotSchedule] ([ID])
GO
ALTER TABLE [dbo].[ReportSnapshotScheduleReportRelation] CHECK CONSTRAINT [FK_ReportSnapshotScheduleReportRelation_ReportSnapshotSubscription]
GO
