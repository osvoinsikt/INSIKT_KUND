SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCDashboardPresentationObjectRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCDashboardID] [int] NOT NULL,
	[X] [int] NOT NULL,
	[Y] [int] NOT NULL,
	[Width] [int] NOT NULL,
	[Height] [int] NOT NULL,
	[FCTypeID] [int] NULL,
	[FCObjectTypeID] [int] NULL,
	[ReportID] [int] NULL,
	[HideHeader] [bit] NOT NULL,
	[HideHeaderIcons] [bit] NOT NULL,
	[OpenRegardlessOfProcessStatus] [bit] NOT NULL,
	[ShowFilterPanel] [bit] NOT NULL,
	[IsReadOnly] [bit] NOT NULL,
	[HideVersionSelector] [bit] NOT NULL,
 CONSTRAINT [PK_FCDashboardPresentationObjectRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCDashboardPresentationObjectRelation] ADD  CONSTRAINT [DF_FCDashboardPresentationObjectRelation_HideHeader]  DEFAULT ((0)) FOR [HideHeader]
GO
ALTER TABLE [dbo].[FCDashboardPresentationObjectRelation] ADD  CONSTRAINT [DF_FCDashboardPresentationObjectRelation_HideHeaderIcons]  DEFAULT ((0)) FOR [HideHeaderIcons]
GO
ALTER TABLE [dbo].[FCDashboardPresentationObjectRelation] ADD  CONSTRAINT [DF_FCDashboardPresentationObjectRelation_ProcessStatus]  DEFAULT ((0)) FOR [OpenRegardlessOfProcessStatus]
GO
ALTER TABLE [dbo].[FCDashboardPresentationObjectRelation] ADD  CONSTRAINT [DF_FCDashboardPresentationObjectRelation_ShowFilterPanel]  DEFAULT ((0)) FOR [ShowFilterPanel]
GO
ALTER TABLE [dbo].[FCDashboardPresentationObjectRelation] ADD  CONSTRAINT [DF_FCDashboardPresentationObjectRelation_IsReadOnly]  DEFAULT ((0)) FOR [IsReadOnly]
GO
ALTER TABLE [dbo].[FCDashboardPresentationObjectRelation] ADD  CONSTRAINT [DF_FCDashboardPresentationObjectRelation_HideVersionSelector]  DEFAULT ((0)) FOR [HideVersionSelector]
GO
ALTER TABLE [dbo].[FCDashboardPresentationObjectRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCDashboardPresentationObjectRelation_FCDashboard] FOREIGN KEY([FCDashboardID])
REFERENCES [dbo].[FCDashboard] ([ID])
GO
ALTER TABLE [dbo].[FCDashboardPresentationObjectRelation] CHECK CONSTRAINT [FK_FCDashboardPresentationObjectRelation_FCDashboard]
GO
ALTER TABLE [dbo].[FCDashboardPresentationObjectRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCDashboardPresentationObjectRelation_FCObjectType] FOREIGN KEY([FCObjectTypeID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[FCDashboardPresentationObjectRelation] CHECK CONSTRAINT [FK_FCDashboardPresentationObjectRelation_FCObjectType]
GO
ALTER TABLE [dbo].[FCDashboardPresentationObjectRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCDashboardPresentationObjectRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCDashboardPresentationObjectRelation] CHECK CONSTRAINT [FK_FCDashboardPresentationObjectRelation_FCType]
GO
ALTER TABLE [dbo].[FCDashboardPresentationObjectRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCDashboardPresentationObjectRelation_Report] FOREIGN KEY([ReportID])
REFERENCES [dbo].[Report] ([ID])
GO
ALTER TABLE [dbo].[FCDashboardPresentationObjectRelation] CHECK CONSTRAINT [FK_FCDashboardPresentationObjectRelation_Report]
GO
