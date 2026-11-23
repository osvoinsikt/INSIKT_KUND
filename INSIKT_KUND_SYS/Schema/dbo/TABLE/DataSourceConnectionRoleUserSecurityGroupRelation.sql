SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSourceConnectionRoleUserSecurityGroupRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceConnectionRoleID] [int] NOT NULL,
	[UserSecurityGroupID] [int] NOT NULL,
 CONSTRAINT [PK_DataSourceConnectionRoleUserSecurityGroupRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataSourceConnectionRoleUserSecurityGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceConnectionRoleUserSecurityGroupRelation_DataSourceConnectionRole] FOREIGN KEY([DataSourceConnectionRoleID])
REFERENCES [dbo].[DataSourceConnectionRole] ([ID])
GO
ALTER TABLE [dbo].[DataSourceConnectionRoleUserSecurityGroupRelation] CHECK CONSTRAINT [FK_DataSourceConnectionRoleUserSecurityGroupRelation_DataSourceConnectionRole]
GO
ALTER TABLE [dbo].[DataSourceConnectionRoleUserSecurityGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceConnectionRoleUserSecurityGroupRelation_UserSecurirtyGroup] FOREIGN KEY([UserSecurityGroupID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[DataSourceConnectionRoleUserSecurityGroupRelation] CHECK CONSTRAINT [FK_DataSourceConnectionRoleUserSecurityGroupRelation_UserSecurirtyGroup]
GO
