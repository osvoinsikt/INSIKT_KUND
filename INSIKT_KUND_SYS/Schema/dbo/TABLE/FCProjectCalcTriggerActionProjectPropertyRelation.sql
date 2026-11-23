SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectCalcTriggerActionProjectPropertyRelation](
	[FCProjectCalcTriggerActionID] [int] NOT NULL,
	[FCProjectCardID] [int] NOT NULL,
 CONSTRAINT [PK_FCProjectCalcTriggerActionProjectPropertyRelation] PRIMARY KEY CLUSTERED 
(
	[FCProjectCalcTriggerActionID] ASC,
	[FCProjectCardID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectCalcTriggerActionProjectPropertyRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTriggerActionProjectPropertyRelation_FCProjectCalcTriggerAction] FOREIGN KEY([FCProjectCalcTriggerActionID])
REFERENCES [dbo].[FCProjectCalcTriggerAction] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerActionProjectPropertyRelation] CHECK CONSTRAINT [FK_FCProjectCalcTriggerActionProjectPropertyRelation_FCProjectCalcTriggerAction]
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerActionProjectPropertyRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTriggerActionProjectPropertyRelation_FCProjectCard] FOREIGN KEY([FCProjectCardID])
REFERENCES [dbo].[FCProjectCard] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerActionProjectPropertyRelation] CHECK CONSTRAINT [FK_FCProjectCalcTriggerActionProjectPropertyRelation_FCProjectCard]
GO
