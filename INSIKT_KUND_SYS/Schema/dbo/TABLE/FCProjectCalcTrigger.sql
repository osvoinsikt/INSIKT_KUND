SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectCalcTrigger](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectCalcTriggerTypeID] [int] NOT NULL,
	[FCVersionID] [int] NULL,
	[FCProjectCalcStepTypeID] [int] NULL,
	[TriggerOnLeave] [bit] NULL,
	[UserInteractionCaption] [nvarchar](50) NULL,
	[UserInteractionCanExecuteSQL] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[ConfirmText] [nvarchar](max) NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[FCProjectCalcCustomTransitionID] [int] NULL,
	[ProcessTemplateActivityRevisionID] [int] NULL,
	[ProcessTemplateActivityStepRevisionID] [int] NULL,
	[TriggerOnFinish] [bit] NULL,
	[Enabled] [bit] NOT NULL,
	[IsGenerated] [bit] NOT NULL,
	[FCVersionCategoryID] [int] NULL,
 CONSTRAINT [PK_FCProjectCalcTrigger] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectCalcTrigger] ADD  CONSTRAINT [DF_FCProjectCalcTrigger_Enabled]  DEFAULT ((1)) FOR [Enabled]
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger] ADD  CONSTRAINT [DF_FCProjectCalcTrigger_IsGenerated]  DEFAULT ((0)) FOR [IsGenerated]
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTrigger_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger] CHECK CONSTRAINT [FK_FCProjectCalcTrigger_CompanyID]
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTrigger_FCProjectCalcCustomTransition] FOREIGN KEY([FCProjectCalcCustomTransitionID])
REFERENCES [dbo].[FCProjectCalcCustomTransition] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger] CHECK CONSTRAINT [FK_FCProjectCalcTrigger_FCProjectCalcCustomTransition]
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTrigger_FCProjectCalcStepType] FOREIGN KEY([FCProjectCalcStepTypeID])
REFERENCES [dbo].[FCProjectCalcStepType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger] CHECK CONSTRAINT [FK_FCProjectCalcTrigger_FCProjectCalcStepType]
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTrigger_FCProjectCalcTriggerType] FOREIGN KEY([FCProjectCalcTriggerTypeID])
REFERENCES [dbo].[FCProjectCalcTriggerType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger] CHECK CONSTRAINT [FK_FCProjectCalcTrigger_FCProjectCalcTriggerType]
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTrigger_FCTypeID] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger] CHECK CONSTRAINT [FK_FCProjectCalcTrigger_FCTypeID]
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTrigger_FCVersion] FOREIGN KEY([FCVersionID])
REFERENCES [dbo].[FCVersion] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger] CHECK CONSTRAINT [FK_FCProjectCalcTrigger_FCVersion]
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTrigger_FCVersionCategory] FOREIGN KEY([FCVersionCategoryID])
REFERENCES [dbo].[FCVersionCategory] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger] CHECK CONSTRAINT [FK_FCProjectCalcTrigger_FCVersionCategory]
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTrigger_ProcessTemplateActivityRevision] FOREIGN KEY([ProcessTemplateActivityRevisionID])
REFERENCES [process].[ProcessTemplateActivityRevision] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger] CHECK CONSTRAINT [FK_FCProjectCalcTrigger_ProcessTemplateActivityRevision]
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTrigger_ProcessTemplateActivityStepRevision] FOREIGN KEY([ProcessTemplateActivityStepRevisionID])
REFERENCES [process].[ProcessTemplateActivityStepRevision] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTrigger] CHECK CONSTRAINT [FK_FCProjectCalcTrigger_ProcessTemplateActivityStepRevision]
GO
