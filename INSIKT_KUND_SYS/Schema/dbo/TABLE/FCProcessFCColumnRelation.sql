SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProcessFCColumnRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProcessID] [int] NULL,
	[FCProjectCalcProcessID] [int] NULL,
	[FCColumnID] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[FinishedDate] [datetime] NULL,
	[FinishedBy] [int] NULL,
	[FinishedByDynamicChoiceID] [int] NULL,
 CONSTRAINT [PK_FCProcessFCColumnRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProcessFCColumnRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProcessFCColumnRelation_FCColumnDynamicChoice] FOREIGN KEY([FinishedByDynamicChoiceID])
REFERENCES [dbo].[FCColumnDynamicChoice] ([ID])
GO
ALTER TABLE [dbo].[FCProcessFCColumnRelation] CHECK CONSTRAINT [FK_FCProcessFCColumnRelation_FCColumnDynamicChoice]
GO
ALTER TABLE [dbo].[FCProcessFCColumnRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProcessFCColumnRelation_FCColumns] FOREIGN KEY([FCColumnID])
REFERENCES [dbo].[FCColumns] ([ID])
GO
ALTER TABLE [dbo].[FCProcessFCColumnRelation] CHECK CONSTRAINT [FK_FCProcessFCColumnRelation_FCColumns]
GO
ALTER TABLE [dbo].[FCProcessFCColumnRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProcessFCColumnRelation_FCProcess] FOREIGN KEY([FCProcessID])
REFERENCES [dbo].[FCProcess] ([ID])
GO
ALTER TABLE [dbo].[FCProcessFCColumnRelation] CHECK CONSTRAINT [FK_FCProcessFCColumnRelation_FCProcess]
GO
ALTER TABLE [dbo].[FCProcessFCColumnRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProcessFCColumnRelation_FCProjectCalcProcess] FOREIGN KEY([FCProjectCalcProcessID])
REFERENCES [dbo].[FCProjectCalcProcess] ([ID])
GO
ALTER TABLE [dbo].[FCProcessFCColumnRelation] CHECK CONSTRAINT [FK_FCProcessFCColumnRelation_FCProjectCalcProcess]
GO
ALTER TABLE [dbo].[FCProcessFCColumnRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProcessFCColumnRelation_UserSecurityGroup_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProcessFCColumnRelation] CHECK CONSTRAINT [FK_FCProcessFCColumnRelation_UserSecurityGroup_CreatedBy]
GO
ALTER TABLE [dbo].[FCProcessFCColumnRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProcessFCColumnRelation_UserSecurityGroup_FinishedBy] FOREIGN KEY([FinishedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProcessFCColumnRelation] CHECK CONSTRAINT [FK_FCProcessFCColumnRelation_UserSecurityGroup_FinishedBy]
GO
