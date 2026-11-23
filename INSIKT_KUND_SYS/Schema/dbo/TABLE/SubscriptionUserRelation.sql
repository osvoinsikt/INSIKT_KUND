SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubscriptionUserRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SubscriptionID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
 CONSTRAINT [PK_SubscriptionUserRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[SubscriptionUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_SubscriptionUserRelation_Subscription] FOREIGN KEY([SubscriptionID])
REFERENCES [dbo].[Subscription] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SubscriptionUserRelation] CHECK CONSTRAINT [FK_SubscriptionUserRelation_Subscription]
GO
ALTER TABLE [dbo].[SubscriptionUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_SubscriptionUserRelation_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[SubscriptionUserRelation] CHECK CONSTRAINT [FK_SubscriptionUserRelation_User]
GO
