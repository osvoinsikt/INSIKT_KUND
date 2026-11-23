SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserGroupRelationLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InitiatedBy] [int] NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[TypeID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[GroupID] [int] NOT NULL,
 CONSTRAINT [PK_UserGroupRelationLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserGroupRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_UserGroupRelationLog_Group] FOREIGN KEY([GroupID])
REFERENCES [dbo].[Group] ([ID])
GO
ALTER TABLE [dbo].[UserGroupRelationLog] CHECK CONSTRAINT [FK_UserGroupRelationLog_Group]
GO
ALTER TABLE [dbo].[UserGroupRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_UserGroupRelationLog_InitiatedBy_UserSecurityGroup] FOREIGN KEY([InitiatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserGroupRelationLog] CHECK CONSTRAINT [FK_UserGroupRelationLog_InitiatedBy_UserSecurityGroup]
GO
ALTER TABLE [dbo].[UserGroupRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_UserGroupRelationLog_UserGroupRelationLogType] FOREIGN KEY([TypeID])
REFERENCES [dbo].[UserGroupRelationLogType] ([ID])
GO
ALTER TABLE [dbo].[UserGroupRelationLog] CHECK CONSTRAINT [FK_UserGroupRelationLog_UserGroupRelationLogType]
GO
ALTER TABLE [dbo].[UserGroupRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_UserGroupRelationLog_UserID_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserGroupRelationLog] CHECK CONSTRAINT [FK_UserGroupRelationLog_UserID_UserSecurityGroup]
GO
