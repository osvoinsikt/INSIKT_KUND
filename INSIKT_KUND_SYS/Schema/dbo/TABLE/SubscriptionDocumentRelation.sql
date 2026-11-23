SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubscriptionDocumentRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SubscriptionID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
 CONSTRAINT [PK_SubscriptionDocumentRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[SubscriptionDocumentRelation]  WITH CHECK ADD  CONSTRAINT [FK_SubscriptionDocumentRelation_Document] FOREIGN KEY([DocumentID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[SubscriptionDocumentRelation] CHECK CONSTRAINT [FK_SubscriptionDocumentRelation_Document]
GO
ALTER TABLE [dbo].[SubscriptionDocumentRelation]  WITH CHECK ADD  CONSTRAINT [FK_SubscriptionDocumentRelation_Subscription] FOREIGN KEY([SubscriptionID])
REFERENCES [dbo].[Subscription] ([ID])
GO
ALTER TABLE [dbo].[SubscriptionDocumentRelation] CHECK CONSTRAINT [FK_SubscriptionDocumentRelation_Subscription]
GO
