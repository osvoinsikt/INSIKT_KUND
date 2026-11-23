SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserSecurityGroupAuthenticationDevice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[Secret] [varchar](50) NOT NULL,
	[Identifier] [varchar](150) NULL,
	[TimeStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_UserSecurityGroupAuthenticationDevice] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[UserSecurityGroupAuthenticationDevice]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupAuthenticationDevice_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroupAuthenticationDevice] CHECK CONSTRAINT [FK_UserSecurityGroupAuthenticationDevice_UserSecurityGroup]
GO
