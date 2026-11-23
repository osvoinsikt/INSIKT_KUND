SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubscriptionReportRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SubscriptionID] [int] NOT NULL,
	[ReportID] [int] NOT NULL,
	[AttachReportInMail] [bit] NOT NULL,
 CONSTRAINT [PK_SubscriptionReportRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[SubscriptionReportRelation]  WITH CHECK ADD  CONSTRAINT [FK_SubscriptionReportRelation_Report] FOREIGN KEY([ReportID])
REFERENCES [dbo].[Report] ([ID])
GO
ALTER TABLE [dbo].[SubscriptionReportRelation] CHECK CONSTRAINT [FK_SubscriptionReportRelation_Report]
GO
ALTER TABLE [dbo].[SubscriptionReportRelation]  WITH CHECK ADD  CONSTRAINT [FK_SubscriptionReportRelation_Subscription] FOREIGN KEY([SubscriptionID])
REFERENCES [dbo].[Subscription] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SubscriptionReportRelation] CHECK CONSTRAINT [FK_SubscriptionReportRelation_Subscription]
GO
