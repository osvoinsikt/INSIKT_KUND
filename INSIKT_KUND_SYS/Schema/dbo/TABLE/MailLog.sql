SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Sender] [nvarchar](max) NOT NULL,
	[Recipient] [nvarchar](max) NOT NULL,
	[ReplyTo] [nvarchar](max) NULL,
	[Subject] [nvarchar](max) NOT NULL,
	[Body] [nvarchar](max) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateSent] [datetime] NULL,
	[StatusID] [int] NOT NULL,
	[TypeID] [int] NOT NULL,
	[StatusMessage] [nvarchar](max) NULL,
	[SendAsPlainText] [bit] NOT NULL,
 CONSTRAINT [PK_MailLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[MailLog] ADD  CONSTRAINT [DF_MailLog_SendAsPlainText]  DEFAULT ((0)) FOR [SendAsPlainText]
GO
ALTER TABLE [dbo].[MailLog]  WITH CHECK ADD  CONSTRAINT [FK_MailLog_MailStatus] FOREIGN KEY([StatusID])
REFERENCES [dbo].[MailStatus] ([ID])
GO
ALTER TABLE [dbo].[MailLog] CHECK CONSTRAINT [FK_MailLog_MailStatus]
GO
ALTER TABLE [dbo].[MailLog]  WITH CHECK ADD  CONSTRAINT [FK_MailLog_MailType] FOREIGN KEY([TypeID])
REFERENCES [dbo].[MailType] ([ID])
GO
ALTER TABLE [dbo].[MailLog] CHECK CONSTRAINT [FK_MailLog_MailType]
GO
