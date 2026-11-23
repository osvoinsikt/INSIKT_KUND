SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AITokenUsage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[Month] [tinyint] NOT NULL,
	[InputTokens] [bigint] NOT NULL,
	[OutputTokens] [bigint] NOT NULL,
	[RequestCount] [int] NOT NULL,
	[DeploymentID] [int] NULL,
 CONSTRAINT [PK_AITokenUsage] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[AITokenUsage] ADD  CONSTRAINT [DF_AITokenUsage_InputTokens]  DEFAULT ((0)) FOR [InputTokens]
GO
ALTER TABLE [dbo].[AITokenUsage] ADD  CONSTRAINT [DF_AITokenUsage_OutputTokens]  DEFAULT ((0)) FOR [OutputTokens]
GO
ALTER TABLE [dbo].[AITokenUsage] ADD  CONSTRAINT [DF_AITokenUsage_RequestCount]  DEFAULT ((0)) FOR [RequestCount]
GO
ALTER TABLE [dbo].[AITokenUsage]  WITH CHECK ADD  CONSTRAINT [FK_AITokenUsage_DeploymentID] FOREIGN KEY([DeploymentID])
REFERENCES [dbo].[AISettings] ([ID])
GO
ALTER TABLE [dbo].[AITokenUsage] CHECK CONSTRAINT [FK_AITokenUsage_DeploymentID]
GO
ALTER TABLE [dbo].[AITokenUsage]  WITH CHECK ADD  CONSTRAINT [FK_AITokenUsage_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[AITokenUsage] CHECK CONSTRAINT [FK_AITokenUsage_UserSecurityGroup]
GO
