SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[Goal](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Status] [int] NOT NULL,
	[ResponsibleUserID] [int] NULL,
	[ModelTypeID] [int] NOT NULL,
	[VersionID] [int] NOT NULL,
	[OrganisationMemberID] [int] NOT NULL,
	[GoalLevelID] [int] NULL,
	[ParentGoalID] [int] NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
	[SortOrder] [int] NOT NULL,
	[ExternalKey] [nvarchar](255) NULL,
 CONSTRAINT [PK_Scorecard_Goal] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [scorecard].[Goal] ADD  CONSTRAINT [DF_Scorecard_Goal_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [scorecard].[Goal]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Goal_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[Goal] CHECK CONSTRAINT [FK_Scorecard_Goal_CreatedBy]
GO
ALTER TABLE [scorecard].[Goal]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Goal_GoalLevel] FOREIGN KEY([GoalLevelID])
REFERENCES [scorecard].[GoalLevel] ([ID])
GO
ALTER TABLE [scorecard].[Goal] CHECK CONSTRAINT [FK_Scorecard_Goal_GoalLevel]
GO
ALTER TABLE [scorecard].[Goal]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Goal_ModelTypeID] FOREIGN KEY([ModelTypeID])
REFERENCES [scorecard].[ModelType] ([ID])
GO
ALTER TABLE [scorecard].[Goal] CHECK CONSTRAINT [FK_Scorecard_Goal_ModelTypeID]
GO
ALTER TABLE [scorecard].[Goal]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Goal_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[Goal] CHECK CONSTRAINT [FK_Scorecard_Goal_ModifiedBy]
GO
ALTER TABLE [scorecard].[Goal]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Goal_OrganisationMember] FOREIGN KEY([OrganisationMemberID])
REFERENCES [scorecard].[OrganisationMember] ([ID])
GO
ALTER TABLE [scorecard].[Goal] CHECK CONSTRAINT [FK_Scorecard_Goal_OrganisationMember]
GO
ALTER TABLE [scorecard].[Goal]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Goal_ParentGoal] FOREIGN KEY([ParentGoalID])
REFERENCES [scorecard].[Goal] ([ID])
GO
ALTER TABLE [scorecard].[Goal] CHECK CONSTRAINT [FK_Scorecard_Goal_ParentGoal]
GO
ALTER TABLE [scorecard].[Goal]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Goal_ResponsibleUser] FOREIGN KEY([ResponsibleUserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[Goal] CHECK CONSTRAINT [FK_Scorecard_Goal_ResponsibleUser]
GO
ALTER TABLE [scorecard].[Goal]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Goal_Status] FOREIGN KEY([Status])
REFERENCES [scorecard].[GoalStatusType] ([ID])
GO
ALTER TABLE [scorecard].[Goal] CHECK CONSTRAINT [FK_Scorecard_Goal_Status]
GO
ALTER TABLE [scorecard].[Goal]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Goal_Version] FOREIGN KEY([VersionID])
REFERENCES [scorecard].[Version] ([ID])
GO
ALTER TABLE [scorecard].[Goal] CHECK CONSTRAINT [FK_Scorecard_Goal_Version]
GO
