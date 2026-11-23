SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleTaskRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RoleID] [int] NOT NULL,
	[TaskID] [int] NOT NULL,
	[FCTypeID] [int] NULL,
	[FCObjectTypeID] [int] NULL,
	[FCProjectCalcStepTypeID] [int] NULL,
	[FCRoleID] [int] NULL,
	[InheritanceTypeID] [int] NULL,
	[FileUploadTypeID] [int] NULL,
 CONSTRAINT [PK_RoleTaskRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[RoleTaskRelation]  WITH CHECK ADD  CONSTRAINT [FK_RoleTaskRelation_FCObjectType] FOREIGN KEY([FCObjectTypeID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[RoleTaskRelation] CHECK CONSTRAINT [FK_RoleTaskRelation_FCObjectType]
GO
ALTER TABLE [dbo].[RoleTaskRelation]  WITH CHECK ADD  CONSTRAINT [FK_RoleTaskRelation_FCProjectCalcStepType] FOREIGN KEY([FCProjectCalcStepTypeID])
REFERENCES [dbo].[FCProjectCalcStepType] ([ID])
GO
ALTER TABLE [dbo].[RoleTaskRelation] CHECK CONSTRAINT [FK_RoleTaskRelation_FCProjectCalcStepType]
GO
ALTER TABLE [dbo].[RoleTaskRelation]  WITH CHECK ADD  CONSTRAINT [FK_RoleTaskRelation_FCRole] FOREIGN KEY([FCRoleID])
REFERENCES [dbo].[FCRole] ([ID])
GO
ALTER TABLE [dbo].[RoleTaskRelation] CHECK CONSTRAINT [FK_RoleTaskRelation_FCRole]
GO
ALTER TABLE [dbo].[RoleTaskRelation]  WITH CHECK ADD  CONSTRAINT [FK_RoleTaskRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[RoleTaskRelation] CHECK CONSTRAINT [FK_RoleTaskRelation_FCType]
GO
ALTER TABLE [dbo].[RoleTaskRelation]  WITH CHECK ADD  CONSTRAINT [FK_RoleTaskRelation_FileUploadType] FOREIGN KEY([FileUploadTypeID])
REFERENCES [dbo].[FileUploadType] ([ID])
GO
ALTER TABLE [dbo].[RoleTaskRelation] CHECK CONSTRAINT [FK_RoleTaskRelation_FileUploadType]
GO
ALTER TABLE [dbo].[RoleTaskRelation]  WITH CHECK ADD  CONSTRAINT [FK_RoleTaskRelation_Role] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Role] ([ID])
GO
ALTER TABLE [dbo].[RoleTaskRelation] CHECK CONSTRAINT [FK_RoleTaskRelation_Role]
GO
ALTER TABLE [dbo].[RoleTaskRelation]  WITH CHECK ADD  CONSTRAINT [FK_RoleTaskRelation_RoleTaskInheritanceType] FOREIGN KEY([InheritanceTypeID])
REFERENCES [dbo].[RoleTaskInheritanceType] ([ID])
GO
ALTER TABLE [dbo].[RoleTaskRelation] CHECK CONSTRAINT [FK_RoleTaskRelation_RoleTaskInheritanceType]
GO
ALTER TABLE [dbo].[RoleTaskRelation]  WITH CHECK ADD  CONSTRAINT [FK_RoleTaskRelation_Task] FOREIGN KEY([TaskID])
REFERENCES [dbo].[Task] ([ID])
GO
ALTER TABLE [dbo].[RoleTaskRelation] CHECK CONSTRAINT [FK_RoleTaskRelation_Task]
GO
