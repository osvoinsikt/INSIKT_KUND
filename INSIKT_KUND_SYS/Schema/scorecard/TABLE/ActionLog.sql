SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[ActionLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ParentActionLogID] [int] NULL,
	[UserID] [int] NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[ModelTypeID] [int] NOT NULL,
	[VersionID] [int] NULL,
	[OrganisationMemberID] [int] NULL,
	[ActionLogTypeID] [int] NOT NULL,
	[GoalID] [int] NULL,
	[ActivityID] [int] NULL,
	[KPIID] [int] NULL,
	[ActionLogPropertyID] [int] NULL,
	[PeriodID] [int] NULL,
	[OldNumericValue] [decimal](18, 8) NULL,
	[OldStringValue] [nvarchar](max) NULL,
	[OldDisplayValue] [nvarchar](max) NULL,
	[NewNumericValue] [decimal](18, 8) NULL,
	[NewStringValue] [nvarchar](max) NULL,
	[NewDisplayValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_Scorecard_ActionLog] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE CLUSTERED INDEX [IX_ScorecardActionLog_ModelTypeVersionOrgEventDate] ON [scorecard].[ActionLog]
(
	[ModelTypeID] ASC,
	[VersionID] ASC,
	[OrganisationMemberID] ASC,
	[EventDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [scorecard].[ActionLog]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActionLog_ActionLogProperty] FOREIGN KEY([ActionLogPropertyID])
REFERENCES [scorecard].[ActionLogProperty] ([ID])
GO
ALTER TABLE [scorecard].[ActionLog] CHECK CONSTRAINT [FK_Scorecard_ActionLog_ActionLogProperty]
GO
ALTER TABLE [scorecard].[ActionLog]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActionLog_ActionLogType] FOREIGN KEY([ActionLogTypeID])
REFERENCES [scorecard].[ActionLogType] ([ID])
GO
ALTER TABLE [scorecard].[ActionLog] CHECK CONSTRAINT [FK_Scorecard_ActionLog_ActionLogType]
GO
ALTER TABLE [scorecard].[ActionLog]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActionLog_Activity] FOREIGN KEY([ActivityID])
REFERENCES [scorecard].[Activity] ([ID])
GO
ALTER TABLE [scorecard].[ActionLog] CHECK CONSTRAINT [FK_Scorecard_ActionLog_Activity]
GO
ALTER TABLE [scorecard].[ActionLog]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActionLog_Goal] FOREIGN KEY([GoalID])
REFERENCES [scorecard].[Goal] ([ID])
GO
ALTER TABLE [scorecard].[ActionLog] CHECK CONSTRAINT [FK_Scorecard_ActionLog_Goal]
GO
ALTER TABLE [scorecard].[ActionLog]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActionLog_KPI] FOREIGN KEY([KPIID])
REFERENCES [scorecard].[KPI] ([ID])
GO
ALTER TABLE [scorecard].[ActionLog] CHECK CONSTRAINT [FK_Scorecard_ActionLog_KPI]
GO
ALTER TABLE [scorecard].[ActionLog]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActionLog_ModelTypeID] FOREIGN KEY([ModelTypeID])
REFERENCES [scorecard].[ModelType] ([ID])
GO
ALTER TABLE [scorecard].[ActionLog] CHECK CONSTRAINT [FK_Scorecard_ActionLog_ModelTypeID]
GO
ALTER TABLE [scorecard].[ActionLog]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActionLog_OrganisationMember] FOREIGN KEY([OrganisationMemberID])
REFERENCES [scorecard].[OrganisationMember] ([ID])
GO
ALTER TABLE [scorecard].[ActionLog] CHECK CONSTRAINT [FK_Scorecard_ActionLog_OrganisationMember]
GO
ALTER TABLE [scorecard].[ActionLog]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActionLog_ParentActionLog] FOREIGN KEY([ParentActionLogID])
REFERENCES [scorecard].[ActionLog] ([ID])
GO
ALTER TABLE [scorecard].[ActionLog] CHECK CONSTRAINT [FK_Scorecard_ActionLog_ParentActionLog]
GO
ALTER TABLE [scorecard].[ActionLog]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActionLog_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[ActionLog] CHECK CONSTRAINT [FK_Scorecard_ActionLog_User]
GO
ALTER TABLE [scorecard].[ActionLog]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActionLog_Version] FOREIGN KEY([VersionID])
REFERENCES [scorecard].[Version] ([ID])
GO
ALTER TABLE [scorecard].[ActionLog] CHECK CONSTRAINT [FK_Scorecard_ActionLog_Version]
GO
