SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSourceConnectionRoleUserSecurityGroupRelationLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InitiatedBy] [int] NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[TypeID] [int] NOT NULL,
	[DataSourceConnectionRoleID] [int] NOT NULL,
	[UserSecurityGroupID] [int] NOT NULL,
 CONSTRAINT [PK_DataSourceConnectionRoleUserSecurityGroupRelationLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataSourceConnectionRoleUserSecurityGroupRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceConnectionRoleUserSecurityGroupRelationLog_Group] FOREIGN KEY([UserSecurityGroupID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[DataSourceConnectionRoleUserSecurityGroupRelationLog] CHECK CONSTRAINT [FK_DataSourceConnectionRoleUserSecurityGroupRelationLog_Group]
GO
ALTER TABLE [dbo].[DataSourceConnectionRoleUserSecurityGroupRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceConnectionRoleUserSecurityGroupRelationLog_InitiatedBy] FOREIGN KEY([InitiatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[DataSourceConnectionRoleUserSecurityGroupRelationLog] CHECK CONSTRAINT [FK_DataSourceConnectionRoleUserSecurityGroupRelationLog_InitiatedBy]
GO
ALTER TABLE [dbo].[DataSourceConnectionRoleUserSecurityGroupRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceConnectionRoleUserSecurityGroupRelationLog_Role] FOREIGN KEY([DataSourceConnectionRoleID])
REFERENCES [dbo].[DataSourceConnectionRole] ([ID])
GO
ALTER TABLE [dbo].[DataSourceConnectionRoleUserSecurityGroupRelationLog] CHECK CONSTRAINT [FK_DataSourceConnectionRoleUserSecurityGroupRelationLog_Role]
GO
ALTER TABLE [dbo].[DataSourceConnectionRoleUserSecurityGroupRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceConnectionRoleUserSecurityGroupRelationLog_Type] FOREIGN KEY([TypeID])
REFERENCES [dbo].[DataSourceConnectionRoleUserSecurityGroupRelationLogType] ([ID])
GO
ALTER TABLE [dbo].[DataSourceConnectionRoleUserSecurityGroupRelationLog] CHECK CONSTRAINT [FK_DataSourceConnectionRoleUserSecurityGroupRelationLog_Type]
GO
