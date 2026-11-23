SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubscriptionGroupRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SubscriptionID] [int] NOT NULL,
	[GroupID] [int] NOT NULL,
 CONSTRAINT [PK_SubscriptionGroupRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[SubscriptionGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_SubscriptionGroupRelation_Group] FOREIGN KEY([GroupID])
REFERENCES [dbo].[Group] ([ID])
GO
ALTER TABLE [dbo].[SubscriptionGroupRelation] CHECK CONSTRAINT [FK_SubscriptionGroupRelation_Group]
GO
ALTER TABLE [dbo].[SubscriptionGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_SubscriptionGroupRelation_Subscription] FOREIGN KEY([SubscriptionID])
REFERENCES [dbo].[Subscription] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SubscriptionGroupRelation] CHECK CONSTRAINT [FK_SubscriptionGroupRelation_Subscription]
GO
