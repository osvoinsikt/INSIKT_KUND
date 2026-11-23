SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSecurityGroupRelation](
	[SecurityGroupID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
 CONSTRAINT [PK_UserSecurityGroupRelation] PRIMARY KEY CLUSTERED 
(
	[SecurityGroupID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserSecurityGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupRelation_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroupRelation] CHECK CONSTRAINT [FK_UserSecurityGroupRelation_User]
GO
ALTER TABLE [dbo].[UserSecurityGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupRelation_User1] FOREIGN KEY([SecurityGroupID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroupRelation] CHECK CONSTRAINT [FK_UserSecurityGroupRelation_User1]
GO
