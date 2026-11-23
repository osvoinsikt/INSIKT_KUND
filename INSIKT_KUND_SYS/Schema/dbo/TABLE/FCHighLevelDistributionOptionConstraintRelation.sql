SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCHighLevelDistributionOptionConstraintRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCHighLevelDistributionOptionID] [int] NOT NULL,
	[ConstraintID] [int] NOT NULL,
 CONSTRAINT [PK_FCHighLevelDistributionOptionConstraintRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCHighLevelDistributionOptionConstraintRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCHighLevelDistributionOptionConstraintRelation_Constraint] FOREIGN KEY([ConstraintID])
REFERENCES [dbo].[Constraint] ([ID])
GO
ALTER TABLE [dbo].[FCHighLevelDistributionOptionConstraintRelation] CHECK CONSTRAINT [FK_FCHighLevelDistributionOptionConstraintRelation_Constraint]
GO
ALTER TABLE [dbo].[FCHighLevelDistributionOptionConstraintRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCHighLevelDistributionOptionConstraintRelation_FCHighLevelDistributionOption] FOREIGN KEY([FCHighLevelDistributionOptionID])
REFERENCES [dbo].[FCHighLevelDistributionOption] ([ID])
GO
ALTER TABLE [dbo].[FCHighLevelDistributionOptionConstraintRelation] CHECK CONSTRAINT [FK_FCHighLevelDistributionOptionConstraintRelation_FCHighLevelDistributionOption]
GO
