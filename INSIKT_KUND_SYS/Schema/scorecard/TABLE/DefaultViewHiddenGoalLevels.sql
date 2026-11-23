SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[DefaultViewHiddenGoalLevels](
	[DefaultViewID] [int] NOT NULL,
	[GoalLevelID] [int] NOT NULL,
 CONSTRAINT [PK_Scorecard_DefaultViewHiddenGoalLevels] PRIMARY KEY CLUSTERED 
(
	[DefaultViewID] ASC,
	[GoalLevelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [scorecard].[DefaultViewHiddenGoalLevels]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_DefaultViewHiddenGoalLevels_DefaultViewID] FOREIGN KEY([DefaultViewID])
REFERENCES [scorecard].[DefaultView] ([ID])
GO
ALTER TABLE [scorecard].[DefaultViewHiddenGoalLevels] CHECK CONSTRAINT [FK_Scorecard_DefaultViewHiddenGoalLevels_DefaultViewID]
GO
ALTER TABLE [scorecard].[DefaultViewHiddenGoalLevels]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_DefaultViewHiddenGoalLevels_GoalLevelID] FOREIGN KEY([GoalLevelID])
REFERENCES [scorecard].[GoalLevel] ([ID])
GO
ALTER TABLE [scorecard].[DefaultViewHiddenGoalLevels] CHECK CONSTRAINT [FK_Scorecard_DefaultViewHiddenGoalLevels_GoalLevelID]
GO
