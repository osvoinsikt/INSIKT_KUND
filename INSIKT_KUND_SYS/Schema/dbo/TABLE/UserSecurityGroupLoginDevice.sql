SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSecurityGroupLoginDevice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[IdentifierGuid] [uniqueidentifier] NOT NULL,
	[RegisterDate] [datetime] NOT NULL,
	[LastLoginDate] [datetime] NOT NULL,
	[TwoFactorAuthRememberDate] [datetime] NULL,
	[Suggested2FADate] [datetime] NULL,
 CONSTRAINT [PK_UserSecurityGroupLoginDevice] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserSecurityGroupLoginDevice]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupLoginDevice_UserID] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroupLoginDevice] CHECK CONSTRAINT [FK_UserSecurityGroupLoginDevice_UserID]
GO
