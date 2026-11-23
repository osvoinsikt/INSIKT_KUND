SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectUserRelationLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InitiatedBy] [int] NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[TypeID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[FCRoleID] [int] NOT NULL,
	[FCProjectPropertyID] [int] NULL,
	[FCProjectPropertyName] [nvarchar](255) NULL,
	[ValueNumeric] [float] NULL,
	[ValueString] [nvarchar](3000) NULL,
	[FCProjectPropertyPredefinedValueID] [int] NULL,
	[VisibleName] [nvarchar](3000) NULL,
	[FCProjectID] [int] NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[GroupID] [int] NULL,
	[AllProjects] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectUserRelationLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectUserRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelationLog_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog] CHECK CONSTRAINT [FK_FCProjectUserRelationLog_Company]
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelationLog_FCProject] FOREIGN KEY([FCProjectID])
REFERENCES [dbo].[FCProject] ([ID])
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog] CHECK CONSTRAINT [FK_FCProjectUserRelationLog_FCProject]
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelationLog_FCProjectProperty] FOREIGN KEY([FCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog] CHECK CONSTRAINT [FK_FCProjectUserRelationLog_FCProjectProperty]
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelationLog_FCProjectPropertyPredefinedValue] FOREIGN KEY([FCProjectPropertyPredefinedValueID])
REFERENCES [dbo].[FCProjectPropertyPredefinedValue] ([ID])
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog] CHECK CONSTRAINT [FK_FCProjectUserRelationLog_FCProjectPropertyPredefinedValue]
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelationLog_FCProjectUserRelationLogType] FOREIGN KEY([TypeID])
REFERENCES [dbo].[FCProjectUserRelationLogType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog] CHECK CONSTRAINT [FK_FCProjectUserRelationLog_FCProjectUserRelationLogType]
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelationLog_FCRole] FOREIGN KEY([FCRoleID])
REFERENCES [dbo].[FCRole] ([ID])
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog] CHECK CONSTRAINT [FK_FCProjectUserRelationLog_FCRole]
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelationLog_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog] CHECK CONSTRAINT [FK_FCProjectUserRelationLog_FCType]
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelationLog_InitiatedBy_UserSecurityGroup] FOREIGN KEY([InitiatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog] CHECK CONSTRAINT [FK_FCProjectUserRelationLog_InitiatedBy_UserSecurityGroup]
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelationLog_UserID_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProjectUserRelationLog] CHECK CONSTRAINT [FK_FCProjectUserRelationLog_UserID_UserSecurityGroup]
GO
