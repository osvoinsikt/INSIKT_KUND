SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[Comment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Comment] [nvarchar](max) NOT NULL,
	[ModelTypeID] [int] NOT NULL,
	[VersionID] [int] NOT NULL,
	[OrganisationMemberID] [int] NULL,
	[GoalID] [int] NULL,
	[ActivityID] [int] NULL,
	[KPIID] [int] NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Scorecard_Comment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [scorecard].[Comment] ADD  CONSTRAINT [DF_Scorecard_Comment_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [scorecard].[Comment]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Comment_ActivityID] FOREIGN KEY([ActivityID])
REFERENCES [scorecard].[Activity] ([ID])
GO
ALTER TABLE [scorecard].[Comment] CHECK CONSTRAINT [FK_Scorecard_Comment_ActivityID]
GO
ALTER TABLE [scorecard].[Comment]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Comment_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[Comment] CHECK CONSTRAINT [FK_Scorecard_Comment_CreatedBy]
GO
ALTER TABLE [scorecard].[Comment]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Comment_GoalID] FOREIGN KEY([GoalID])
REFERENCES [scorecard].[Goal] ([ID])
GO
ALTER TABLE [scorecard].[Comment] CHECK CONSTRAINT [FK_Scorecard_Comment_GoalID]
GO
ALTER TABLE [scorecard].[Comment]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Comment_KPIID] FOREIGN KEY([KPIID])
REFERENCES [scorecard].[KPI] ([ID])
GO
ALTER TABLE [scorecard].[Comment] CHECK CONSTRAINT [FK_Scorecard_Comment_KPIID]
GO
ALTER TABLE [scorecard].[Comment]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Comment_ModelTypeID] FOREIGN KEY([ModelTypeID])
REFERENCES [scorecard].[ModelType] ([ID])
GO
ALTER TABLE [scorecard].[Comment] CHECK CONSTRAINT [FK_Scorecard_Comment_ModelTypeID]
GO
ALTER TABLE [scorecard].[Comment]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Comment_OrganisationMemberID] FOREIGN KEY([OrganisationMemberID])
REFERENCES [scorecard].[OrganisationMember] ([ID])
GO
ALTER TABLE [scorecard].[Comment] CHECK CONSTRAINT [FK_Scorecard_Comment_OrganisationMemberID]
GO
ALTER TABLE [scorecard].[Comment]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Comment_VersionID] FOREIGN KEY([VersionID])
REFERENCES [scorecard].[Version] ([ID])
GO
ALTER TABLE [scorecard].[Comment] CHECK CONSTRAINT [FK_Scorecard_Comment_VersionID]
GO
