SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectCalcStepUserRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectCalcStepID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
 CONSTRAINT [PK_FCProjectCalcStepUserRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectCalcStepUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStepUserRelation_FCProjectCalcStep] FOREIGN KEY([FCProjectCalcStepID])
REFERENCES [dbo].[FCProjectCalcStep] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcStepUserRelation] CHECK CONSTRAINT [FK_FCProjectCalcStepUserRelation_FCProjectCalcStep]
GO
ALTER TABLE [dbo].[FCProjectCalcStepUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStepUserRelation_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProjectCalcStepUserRelation] CHECK CONSTRAINT [FK_FCProjectCalcStepUserRelation_UserSecurityGroup]
GO
