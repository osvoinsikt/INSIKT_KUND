SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSecurityGroupBlockedFromLogin](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[Username] [nvarchar](255) NULL,
	[FromDate] [datetime] NOT NULL,
	[ToDate] [datetime] NULL,
	[TypeID] [int] NOT NULL,
	[BlockedBy] [int] NULL,
 CONSTRAINT [PK_UserSecurityGroupBlockedFromLogin] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserSecurityGroupBlockedFromLogin]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupBlockedFromLogin_BlockedBy] FOREIGN KEY([BlockedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroupBlockedFromLogin] CHECK CONSTRAINT [FK_UserSecurityGroupBlockedFromLogin_BlockedBy]
GO
ALTER TABLE [dbo].[UserSecurityGroupBlockedFromLogin]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupBlockedFromLogin_UserID] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroupBlockedFromLogin] CHECK CONSTRAINT [FK_UserSecurityGroupBlockedFromLogin_UserID]
GO
ALTER TABLE [dbo].[UserSecurityGroupBlockedFromLogin]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupBlockedFromLogin_UserSecurityGroupBlockedFromLoginType] FOREIGN KEY([TypeID])
REFERENCES [dbo].[UserSecurityGroupBlockedFromLoginType] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroupBlockedFromLogin] CHECK CONSTRAINT [FK_UserSecurityGroupBlockedFromLogin_UserSecurityGroupBlockedFromLoginType]
GO
