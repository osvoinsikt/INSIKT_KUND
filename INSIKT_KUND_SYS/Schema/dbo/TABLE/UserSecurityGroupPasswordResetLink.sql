SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserSecurityGroupPasswordResetLink](
	[UserID] [int] NOT NULL,
	[LinkId] [char](60) NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[Consumed] [bit] NOT NULL,
 CONSTRAINT [PK_UserSecurityGroupPasswordResetLink] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[UserSecurityGroupPasswordResetLink]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupPasswordResetLink_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroupPasswordResetLink] CHECK CONSTRAINT [FK_UserSecurityGroupPasswordResetLink_UserSecurityGroup]
GO
