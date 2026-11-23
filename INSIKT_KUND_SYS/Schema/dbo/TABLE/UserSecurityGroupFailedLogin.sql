SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserSecurityGroupFailedLogin](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[UserName] [varchar](255) NULL,
	[LoginAttemptDate] [datetime] NOT NULL,
	[HostAddress] [nvarchar](50) NULL,
	[LoginDeviceID] [int] NULL,
	[AuthenticationMethodID] [int] NOT NULL,
 CONSTRAINT [PK_UserSecurityGroupFailedLogin] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[UserSecurityGroupFailedLogin]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupFailedLogin_LoginDevice] FOREIGN KEY([LoginDeviceID])
REFERENCES [dbo].[UserSecurityGroupLoginDevice] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroupFailedLogin] CHECK CONSTRAINT [FK_UserSecurityGroupFailedLogin_LoginDevice]
GO
ALTER TABLE [dbo].[UserSecurityGroupFailedLogin]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupFailedLogin_UserID] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroupFailedLogin] CHECK CONSTRAINT [FK_UserSecurityGroupFailedLogin_UserID]
GO
ALTER TABLE [dbo].[UserSecurityGroupFailedLogin]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupFailedLogin_UserSecurityGroupAuthenticationMethod] FOREIGN KEY([AuthenticationMethodID])
REFERENCES [dbo].[UserSecurityGroupAuthenticationMethod] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroupFailedLogin] CHECK CONSTRAINT [FK_UserSecurityGroupFailedLogin_UserSecurityGroupAuthenticationMethod]
GO
