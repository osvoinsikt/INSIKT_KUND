SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[ActivityGoalRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ActivityID] [int] NOT NULL,
	[GoalID] [int] NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_Scorecard_ActivityGoalRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [scorecard].[ActivityGoalRelation]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActivityGoalRelation_Activity] FOREIGN KEY([ActivityID])
REFERENCES [scorecard].[Activity] ([ID])
GO
ALTER TABLE [scorecard].[ActivityGoalRelation] CHECK CONSTRAINT [FK_Scorecard_ActivityGoalRelation_Activity]
GO
ALTER TABLE [scorecard].[ActivityGoalRelation]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActivityGoalRelation_Goal] FOREIGN KEY([GoalID])
REFERENCES [scorecard].[Goal] ([ID])
GO
ALTER TABLE [scorecard].[ActivityGoalRelation] CHECK CONSTRAINT [FK_Scorecard_ActivityGoalRelation_Goal]
GO
