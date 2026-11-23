SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdminPageViewLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[RunningAsUserID] [int] NULL,
	[EventDate] [datetime] NOT NULL,
	[PageTypeID] [int] NOT NULL,
	[FCTypeID] [int] NULL,
	[ScorecardModelTypeID] [int] NULL,
 CONSTRAINT [PK_AdminPageViewLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[AdminPageViewLog]  WITH CHECK ADD  CONSTRAINT [FK_AdminPageViewLog_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[AdminPageViewLog] CHECK CONSTRAINT [FK_AdminPageViewLog_FCType]
GO
ALTER TABLE [dbo].[AdminPageViewLog]  WITH CHECK ADD  CONSTRAINT [FK_AdminPageViewLog_PageType] FOREIGN KEY([PageTypeID])
REFERENCES [dbo].[AdminPageViewLogType] ([ID])
GO
ALTER TABLE [dbo].[AdminPageViewLog] CHECK CONSTRAINT [FK_AdminPageViewLog_PageType]
GO
ALTER TABLE [dbo].[AdminPageViewLog]  WITH CHECK ADD  CONSTRAINT [FK_AdminPageViewLog_RunningAsUser] FOREIGN KEY([RunningAsUserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[AdminPageViewLog] CHECK CONSTRAINT [FK_AdminPageViewLog_RunningAsUser]
GO
ALTER TABLE [dbo].[AdminPageViewLog]  WITH CHECK ADD  CONSTRAINT [FK_AdminPageViewLog_ScorecardModelType] FOREIGN KEY([ScorecardModelTypeID])
REFERENCES [scorecard].[ModelType] ([ID])
GO
ALTER TABLE [dbo].[AdminPageViewLog] CHECK CONSTRAINT [FK_AdminPageViewLog_ScorecardModelType]
GO
ALTER TABLE [dbo].[AdminPageViewLog]  WITH CHECK ADD  CONSTRAINT [FK_AdminPageViewLog_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[AdminPageViewLog] CHECK CONSTRAINT [FK_AdminPageViewLog_User]
GO
