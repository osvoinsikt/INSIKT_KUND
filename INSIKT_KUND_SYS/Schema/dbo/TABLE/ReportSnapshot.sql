SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReportSnapshot](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReportID] [int] NOT NULL,
	[ReportTypeID] [int] NOT NULL,
	[Comment] [nvarchar](max) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[ParentReportSnapshotID] [int] NULL,
	[ReportData] [xml] NOT NULL,
	[ReportDataVersion] [int] NOT NULL,
	[GridData] [xml] NULL,
	[ReportCommentsData] [xml] NULL,
	[IsDeleted] [bit] NOT NULL,
	[TrendLineData] [xml] NULL,
	[ReportTitle] [varchar](200) NULL,
 CONSTRAINT [PK_ReportSnapshot] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[ReportSnapshot] ADD  CONSTRAINT [DF_ReportSnapshot_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ReportSnapshot]  WITH CHECK ADD  CONSTRAINT [FK_ReportSnapshot_Report] FOREIGN KEY([ReportID])
REFERENCES [dbo].[Report] ([ID])
GO
ALTER TABLE [dbo].[ReportSnapshot] CHECK CONSTRAINT [FK_ReportSnapshot_Report]
GO
ALTER TABLE [dbo].[ReportSnapshot]  WITH CHECK ADD  CONSTRAINT [FK_ReportSnapshot_ReportSnapshot] FOREIGN KEY([ParentReportSnapshotID])
REFERENCES [dbo].[ReportSnapshot] ([ID])
GO
ALTER TABLE [dbo].[ReportSnapshot] CHECK CONSTRAINT [FK_ReportSnapshot_ReportSnapshot]
GO
ALTER TABLE [dbo].[ReportSnapshot]  WITH CHECK ADD  CONSTRAINT [FK_ReportSnapshot_ReportType] FOREIGN KEY([ReportTypeID])
REFERENCES [dbo].[ReportType] ([ID])
GO
ALTER TABLE [dbo].[ReportSnapshot] CHECK CONSTRAINT [FK_ReportSnapshot_ReportType]
GO
ALTER TABLE [dbo].[ReportSnapshot]  WITH CHECK ADD  CONSTRAINT [FK_ReportSnapshot_UserSecurityGroup] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[ReportSnapshot] CHECK CONSTRAINT [FK_ReportSnapshot_UserSecurityGroup]
GO
