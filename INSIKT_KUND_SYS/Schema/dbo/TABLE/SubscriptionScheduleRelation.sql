SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubscriptionScheduleRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SubscriptionID] [int] NOT NULL,
	[ScheduleID] [int] NOT NULL,
 CONSTRAINT [PK_SubscriptionScheduleRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[SubscriptionScheduleRelation]  WITH CHECK ADD  CONSTRAINT [FK_SubscriptionScheduleRelation_Schedule] FOREIGN KEY([ScheduleID])
REFERENCES [dbo].[Schedule] ([ID])
GO
ALTER TABLE [dbo].[SubscriptionScheduleRelation] CHECK CONSTRAINT [FK_SubscriptionScheduleRelation_Schedule]
GO
ALTER TABLE [dbo].[SubscriptionScheduleRelation]  WITH CHECK ADD  CONSTRAINT [FK_SubscriptionScheduleRelation_Subscription] FOREIGN KEY([SubscriptionID])
REFERENCES [dbo].[Subscription] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SubscriptionScheduleRelation] CHECK CONSTRAINT [FK_SubscriptionScheduleRelation_Subscription]
GO
