SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[UserRecentSelection](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[RunningAsUserID] [int] NULL,
	[ModelTypeID] [int] NOT NULL,
	[OrganisationMemberID] [int] NOT NULL,
	[OrganisationMemberName] [nvarchar](255) NOT NULL,
	[VersionID] [int] NOT NULL,
	[VersionName] [nvarchar](255) NOT NULL,
	[OpenedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Scorecard_UserRecentSelection] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_Scorecard_UserRecentSelection] ON [scorecard].[UserRecentSelection]
(
	[UserID] ASC,
	[RunningAsUserID] ASC,
	[ModelTypeID] ASC,
	[OrganisationMemberID] ASC,
	[OpenedDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [scorecard].[UserRecentSelection]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_UserRecentSelection_ModelType] FOREIGN KEY([ModelTypeID])
REFERENCES [scorecard].[ModelType] ([ID])
GO
ALTER TABLE [scorecard].[UserRecentSelection] CHECK CONSTRAINT [FK_Scorecard_UserRecentSelection_ModelType]
GO
ALTER TABLE [scorecard].[UserRecentSelection]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_UserRecentSelection_OrganisationMember] FOREIGN KEY([OrganisationMemberID])
REFERENCES [scorecard].[OrganisationMember] ([ID])
GO
ALTER TABLE [scorecard].[UserRecentSelection] CHECK CONSTRAINT [FK_Scorecard_UserRecentSelection_OrganisationMember]
GO
ALTER TABLE [scorecard].[UserRecentSelection]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_UserRecentSelection_RunningAsUser] FOREIGN KEY([RunningAsUserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[UserRecentSelection] CHECK CONSTRAINT [FK_Scorecard_UserRecentSelection_RunningAsUser]
GO
ALTER TABLE [scorecard].[UserRecentSelection]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_UserRecentSelection_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[UserRecentSelection] CHECK CONSTRAINT [FK_Scorecard_UserRecentSelection_User]
GO
ALTER TABLE [scorecard].[UserRecentSelection]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_UserRecentSelection_Version] FOREIGN KEY([VersionID])
REFERENCES [scorecard].[Version] ([ID])
GO
ALTER TABLE [scorecard].[UserRecentSelection] CHECK CONSTRAINT [FK_Scorecard_UserRecentSelection_Version]
GO
