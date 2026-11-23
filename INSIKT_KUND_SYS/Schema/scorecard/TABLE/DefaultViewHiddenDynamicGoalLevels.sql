SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[DefaultViewHiddenDynamicGoalLevels](
	[DefaultViewID] [int] NOT NULL,
	[OrganisationMemberID] [int] NOT NULL,
 CONSTRAINT [PK_Scorecard_DefaultViewHiddenDynamicGoalLevels] PRIMARY KEY CLUSTERED 
(
	[DefaultViewID] ASC,
	[OrganisationMemberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [scorecard].[DefaultViewHiddenDynamicGoalLevels]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_DefaultViewHiddenDynamicGoalLevels_DefaultViewID] FOREIGN KEY([DefaultViewID])
REFERENCES [scorecard].[DefaultView] ([ID])
GO
ALTER TABLE [scorecard].[DefaultViewHiddenDynamicGoalLevels] CHECK CONSTRAINT [FK_Scorecard_DefaultViewHiddenDynamicGoalLevels_DefaultViewID]
GO
ALTER TABLE [scorecard].[DefaultViewHiddenDynamicGoalLevels]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_DefaultViewHiddenDynamicGoalLevels_OrganisationMemberID] FOREIGN KEY([OrganisationMemberID])
REFERENCES [scorecard].[OrganisationMember] ([ID])
GO
ALTER TABLE [scorecard].[DefaultViewHiddenDynamicGoalLevels] CHECK CONSTRAINT [FK_Scorecard_DefaultViewHiddenDynamicGoalLevels_OrganisationMemberID]
GO
