SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserReadMessageRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[messageID] [int] NOT NULL,
	[userid] [int] NOT NULL,
 CONSTRAINT [PK_UserReadMessageRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserReadMessageRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserReadMessageRelation_FCMessage] FOREIGN KEY([messageID])
REFERENCES [dbo].[FCMessage] ([ID])
GO
ALTER TABLE [dbo].[UserReadMessageRelation] CHECK CONSTRAINT [FK_UserReadMessageRelation_FCMessage]
GO
ALTER TABLE [dbo].[UserReadMessageRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserReadMessageRelation_UserSecurityGroup] FOREIGN KEY([userid])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserReadMessageRelation] CHECK CONSTRAINT [FK_UserReadMessageRelation_UserSecurityGroup]
GO
