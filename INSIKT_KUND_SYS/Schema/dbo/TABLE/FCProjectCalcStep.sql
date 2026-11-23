SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectCalcStep](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectCalcStepTypeID] [int] NOT NULL,
	[FCProjectCalcProcessID] [int] NOT NULL,
	[Order] [int] NOT NULL,
	[FinishedDate] [datetime] NULL,
	[FinishedBy] [int] NULL,
	[IsFinished]  AS (isnull(case when [FinishedDate] IS NULL then (0) else (1) end,(0))),
 CONSTRAINT [PK_FCProjectCalcStep] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectCalcStep]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStep_FCProjectCalcProcess] FOREIGN KEY([FCProjectCalcProcessID])
REFERENCES [dbo].[FCProjectCalcProcess] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcStep] CHECK CONSTRAINT [FK_FCProjectCalcStep_FCProjectCalcProcess]
GO
ALTER TABLE [dbo].[FCProjectCalcStep]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStep_FCProjectCalcStepType] FOREIGN KEY([FCProjectCalcStepTypeID])
REFERENCES [dbo].[FCProjectCalcStepType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcStep] CHECK CONSTRAINT [FK_FCProjectCalcStep_FCProjectCalcStepType]
GO
ALTER TABLE [dbo].[FCProjectCalcStep]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStep_UserSecurityGroup] FOREIGN KEY([FinishedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProjectCalcStep] CHECK CONSTRAINT [FK_FCProjectCalcStep_UserSecurityGroup]
GO
