SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSecurityGroupLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InitiatedBy] [int] NULL,
	[EventDate] [datetime] NOT NULL,
	[TypeID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[RelatedSecurityGroupID] [int] NULL,
	[RoleID] [int] NULL,
	[PropertyID] [int] NULL,
	[OldValue] [nvarchar](255) NULL,
	[OldDisplayValue] [nvarchar](255) NULL,
	[NewValue] [nvarchar](255) NULL,
	[NewDisplayValue] [nvarchar](255) NULL,
 CONSTRAINT [PK_UserSecurityGroupLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserSecurityGroupLog]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupLog_InitiatedBy_UserSecurityGroup] FOREIGN KEY([InitiatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroupLog] CHECK CONSTRAINT [FK_UserSecurityGroupLog_InitiatedBy_UserSecurityGroup]
GO
ALTER TABLE [dbo].[UserSecurityGroupLog]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupLog_RelatedSecurityGroupID_UserSecurityGroup] FOREIGN KEY([RelatedSecurityGroupID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroupLog] CHECK CONSTRAINT [FK_UserSecurityGroupLog_RelatedSecurityGroupID_UserSecurityGroup]
GO
ALTER TABLE [dbo].[UserSecurityGroupLog]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupLog_TypeID_UserSecurityGroupLogType] FOREIGN KEY([TypeID])
REFERENCES [dbo].[UserSecurityGroupLogType] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroupLog] CHECK CONSTRAINT [FK_UserSecurityGroupLog_TypeID_UserSecurityGroupLogType]
GO
ALTER TABLE [dbo].[UserSecurityGroupLog]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupLog_UserID_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroupLog] CHECK CONSTRAINT [FK_UserSecurityGroupLog_UserID_UserSecurityGroup]
GO
ALTER TABLE [dbo].[UserSecurityGroupLog]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupLog_UserSecurityGroupLogProperty] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[UserSecurityGroupLogProperty] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroupLog] CHECK CONSTRAINT [FK_UserSecurityGroupLog_UserSecurityGroupLogProperty]
GO
