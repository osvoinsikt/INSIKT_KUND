SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectCalcCustomTransition](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StepTypeID] [int] NOT NULL,
	[TargetStepTypeID] [int] NOT NULL,
	[ActionCaption] [nvarchar](150) NOT NULL,
	[ConfirmText] [nvarchar](max) NULL,
 CONSTRAINT [PK_FCProjectCalcCustomTransition] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectCalcCustomTransition]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcCustomTransition_FCProjectCalcStepType_StepTypeID] FOREIGN KEY([StepTypeID])
REFERENCES [dbo].[FCProjectCalcStepType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcCustomTransition] CHECK CONSTRAINT [FK_FCProjectCalcCustomTransition_FCProjectCalcStepType_StepTypeID]
GO
ALTER TABLE [dbo].[FCProjectCalcCustomTransition]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcCustomTransition_FCProjectCalcStepType_TargetStepTypeID] FOREIGN KEY([TargetStepTypeID])
REFERENCES [dbo].[FCProjectCalcStepType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcCustomTransition] CHECK CONSTRAINT [FK_FCProjectCalcCustomTransition_FCProjectCalcStepType_TargetStepTypeID]
GO
