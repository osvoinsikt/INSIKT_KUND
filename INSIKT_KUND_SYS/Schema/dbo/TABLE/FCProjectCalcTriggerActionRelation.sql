SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectCalcTriggerActionRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectCalcTriggerID] [int] NOT NULL,
	[FCProjectCalcTriggerActionID] [int] NOT NULL,
	[SortOrder] [int] NULL,
 CONSTRAINT [PK_FCProjectCalcTriggerActionRelation_1] PRIMARY KEY CLUSTERED 
(
	[FCProjectCalcTriggerID] ASC,
	[FCProjectCalcTriggerActionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectCalcTriggerActionRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTriggerActionRelation_FCProjectCalcTrigger] FOREIGN KEY([FCProjectCalcTriggerID])
REFERENCES [dbo].[FCProjectCalcTrigger] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerActionRelation] CHECK CONSTRAINT [FK_FCProjectCalcTriggerActionRelation_FCProjectCalcTrigger]
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerActionRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTriggerActionRelation_FCProjectCalcTriggerAction] FOREIGN KEY([FCProjectCalcTriggerActionID])
REFERENCES [dbo].[FCProjectCalcTriggerAction] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerActionRelation] CHECK CONSTRAINT [FK_FCProjectCalcTriggerActionRelation_FCProjectCalcTriggerAction]
GO
