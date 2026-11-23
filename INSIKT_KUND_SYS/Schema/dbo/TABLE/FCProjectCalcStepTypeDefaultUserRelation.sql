SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[FCProjectPropertyFilterID] [int] NULL,
	[FCVersionID] [int] NULL,
	[FCProjectCalcStepTypeID] [int] NULL,
	[UserID] [int] NULL,
	[CopyFromPreviousFCVersion] [bit] NULL,
	[FCProjectPropertyIDWithUser] [int] NULL,
	[SQLToPresetUser] [nvarchar](max) NULL,
	[IsRequiredAndExclusive] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectCalcStepTypeDefaultUserRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation] ADD  CONSTRAINT [DF_FCProjectCalcStepTypeDefaultUserRelation_IsRequiredAndExclusive]  DEFAULT ((0)) FOR [IsRequiredAndExclusive]
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStepTypeDefaultUserRelation_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation] CHECK CONSTRAINT [FK_FCProjectCalcStepTypeDefaultUserRelation_Company]
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStepTypeDefaultUserRelation_FCProjectCalcStepType] FOREIGN KEY([FCProjectCalcStepTypeID])
REFERENCES [dbo].[FCProjectCalcStepType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation] CHECK CONSTRAINT [FK_FCProjectCalcStepTypeDefaultUserRelation_FCProjectCalcStepType]
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStepTypeDefaultUserRelation_FCProjectProperty] FOREIGN KEY([FCProjectPropertyIDWithUser])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation] CHECK CONSTRAINT [FK_FCProjectCalcStepTypeDefaultUserRelation_FCProjectProperty]
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStepTypeDefaultUserRelation_FCProjectPropertyFilter] FOREIGN KEY([FCProjectPropertyFilterID])
REFERENCES [dbo].[FCProjectPropertyFilter] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation] CHECK CONSTRAINT [FK_FCProjectCalcStepTypeDefaultUserRelation_FCProjectPropertyFilter]
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStepTypeDefaultUserRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation] CHECK CONSTRAINT [FK_FCProjectCalcStepTypeDefaultUserRelation_FCType]
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStepTypeDefaultUserRelation_FCVersion] FOREIGN KEY([FCVersionID])
REFERENCES [dbo].[FCVersion] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation] CHECK CONSTRAINT [FK_FCProjectCalcStepTypeDefaultUserRelation_FCVersion]
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStepTypeDefaultUserRelation_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeDefaultUserRelation] CHECK CONSTRAINT [FK_FCProjectCalcStepTypeDefaultUserRelation_UserSecurityGroup]
GO
