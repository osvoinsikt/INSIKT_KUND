SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectCalcTriggerAction](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectCalcTriggerActionTypeID] [int] NOT NULL,
	[FCProjectPropertyID] [int] NULL,
	[FCProjectPropertyValueString] [nvarchar](max) NULL,
	[FCProjectPropertyValueNumeric] [float] NULL,
	[FCProjectPropertyPredefinedValueID] [int] NULL,
	[SQLScript] [nvarchar](max) NULL,
	[MailRecipient] [nvarchar](250) NULL,
	[MailSubject] [nvarchar](max) NULL,
	[MailBody] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[FCTypeID] [int] NOT NULL,
	[Enabled] [bit] NOT NULL,
	[MailRecipientFCRoleID] [int] NULL,
	[SendNotification] [bit] NOT NULL,
	[SendMail] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectCalcTriggerAction] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectCalcTriggerAction] ADD  CONSTRAINT [DF_FCProjectCalcTriggerAction_Enabled]  DEFAULT ((1)) FOR [Enabled]
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerAction] ADD  CONSTRAINT [DF_FCProjectCalcTriggerAction_SendNotification]  DEFAULT ((0)) FOR [SendNotification]
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerAction] ADD  CONSTRAINT [DF_FCProjectCalcTriggerAction_SendMail]  DEFAULT ((0)) FOR [SendMail]
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerAction]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTriggerAction_FCProjectCalcTriggerActionType] FOREIGN KEY([FCProjectCalcTriggerActionTypeID])
REFERENCES [dbo].[FCProjectCalcTriggerActionType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerAction] CHECK CONSTRAINT [FK_FCProjectCalcTriggerAction_FCProjectCalcTriggerActionType]
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerAction]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTriggerAction_FCProjectProperty] FOREIGN KEY([FCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerAction] CHECK CONSTRAINT [FK_FCProjectCalcTriggerAction_FCProjectProperty]
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerAction]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTriggerAction_FCRole] FOREIGN KEY([MailRecipientFCRoleID])
REFERENCES [dbo].[FCRole] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerAction] CHECK CONSTRAINT [FK_FCProjectCalcTriggerAction_FCRole]
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerAction]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcTriggerAction_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcTriggerAction] CHECK CONSTRAINT [FK_FCProjectCalcTriggerAction_FCType]
GO
