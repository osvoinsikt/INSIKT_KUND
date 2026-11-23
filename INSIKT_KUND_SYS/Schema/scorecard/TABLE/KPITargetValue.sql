SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[KPITargetValue](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KPIID] [int] NOT NULL,
	[Value] [decimal](18, 8) NULL,
	[PeriodID] [int] NOT NULL,
	[OrganisationMemberID] [int] NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsExportedToIntegrationArea] [bit] NOT NULL,
	[ExportedToIntegrationAreaDate] [datetime] NULL,
 CONSTRAINT [PK_Scorecard_KPITargetValue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [scorecard].[KPITargetValue] ADD  CONSTRAINT [DF_Scorecard_KPITargetValue_IsExportedToIntegrationArea]  DEFAULT ((0)) FOR [IsExportedToIntegrationArea]
GO
ALTER TABLE [scorecard].[KPITargetValue]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPITargetValue_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[KPITargetValue] CHECK CONSTRAINT [FK_Scorecard_KPITargetValue_CreatedBy]
GO
ALTER TABLE [scorecard].[KPITargetValue]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPITargetValue_KPI] FOREIGN KEY([KPIID])
REFERENCES [scorecard].[KPI] ([ID])
GO
ALTER TABLE [scorecard].[KPITargetValue] CHECK CONSTRAINT [FK_Scorecard_KPITargetValue_KPI]
GO
ALTER TABLE [scorecard].[KPITargetValue]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPITargetValue_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[KPITargetValue] CHECK CONSTRAINT [FK_Scorecard_KPITargetValue_ModifiedBy]
GO
ALTER TABLE [scorecard].[KPITargetValue]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPITargetValue_OrganisationMember] FOREIGN KEY([OrganisationMemberID])
REFERENCES [scorecard].[OrganisationMember] ([ID])
GO
ALTER TABLE [scorecard].[KPITargetValue] CHECK CONSTRAINT [FK_Scorecard_KPITargetValue_OrganisationMember]
GO
