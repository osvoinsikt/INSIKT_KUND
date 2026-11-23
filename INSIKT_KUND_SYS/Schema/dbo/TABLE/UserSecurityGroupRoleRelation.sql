SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSecurityGroupRoleRelation](
	[UserID] [int] NOT NULL,
	[RoleID] [int] NOT NULL,
 CONSTRAINT [PK_UserSecurityGroupRoleRelation_1] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserSecurityGroupRoleRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupRoleRelation_Role] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Role] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroupRoleRelation] CHECK CONSTRAINT [FK_UserSecurityGroupRoleRelation_Role]
GO
ALTER TABLE [dbo].[UserSecurityGroupRoleRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupRoleRelation_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroupRoleRelation] CHECK CONSTRAINT [FK_UserSecurityGroupRoleRelation_UserSecurityGroup]
GO
