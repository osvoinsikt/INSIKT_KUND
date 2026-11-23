SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectCalcStepVersionCategoryTypeRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCVersionCategoryID] [int] NOT NULL,
	[FCProjectCalcStepTypeID] [int] NOT NULL,
	[Order] [int] NOT NULL,
	[IsOptional] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectCalcStepVersionCategoryRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectCalcStepVersionCategoryTypeRelation] ADD  CONSTRAINT [DF_FCProjectCalcStepVersionCategoryTypeRelation_IsOptional]  DEFAULT ((0)) FOR [IsOptional]
GO
ALTER TABLE [dbo].[FCProjectCalcStepVersionCategoryTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStepVersionCategoryRelation_FCProjectCalcStepType] FOREIGN KEY([FCProjectCalcStepTypeID])
REFERENCES [dbo].[FCProjectCalcStepType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcStepVersionCategoryTypeRelation] CHECK CONSTRAINT [FK_FCProjectCalcStepVersionCategoryRelation_FCProjectCalcStepType]
GO
ALTER TABLE [dbo].[FCProjectCalcStepVersionCategoryTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStepVersionCategoryRelation_FCVersionCategory] FOREIGN KEY([FCVersionCategoryID])
REFERENCES [dbo].[FCVersionCategory] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcStepVersionCategoryTypeRelation] CHECK CONSTRAINT [FK_FCProjectCalcStepVersionCategoryRelation_FCVersionCategory]
GO
