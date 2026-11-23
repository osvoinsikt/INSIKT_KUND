SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserSecurityGroupPropertyValue](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[UserSecurityGroupPropertyID] [int] NOT NULL,
	[Value] [varchar](250) NOT NULL,
 CONSTRAINT [PK_UserSecurityGroupPropertyValue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[UserSecurityGroupPropertyValue]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupPropertyValue_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserSecurityGroupPropertyValue] CHECK CONSTRAINT [FK_UserSecurityGroupPropertyValue_UserSecurityGroup]
GO
ALTER TABLE [dbo].[UserSecurityGroupPropertyValue]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupPropertyValue_UserSecurityGroupProperty] FOREIGN KEY([UserSecurityGroupPropertyID])
REFERENCES [dbo].[UserSecurityGroupProperty] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroupPropertyValue] CHECK CONSTRAINT [FK_UserSecurityGroupPropertyValue_UserSecurityGroupProperty]
GO
