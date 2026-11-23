SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCRecentSelection](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[ViewMode] [int] NULL,
	[ElementKey] [nvarchar](255) NOT NULL,
	[Caption] [nvarchar](max) NOT NULL,
	[UserID] [int] NOT NULL,
	[SelectedDate] [datetime] NOT NULL,
	[RunningAsUserID] [int] NULL,
	[UsedAsAIContext] [bit] NOT NULL,
 CONSTRAINT [PK_FCRecentSelection] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [ix_FCRecentSelection] ON [dbo].[FCRecentSelection]
(
	[UserID] ASC,
	[RunningAsUserID] ASC,
	[FCTypeID] ASC,
	[CompanyID] ASC,
	[ViewMode] ASC,
	[ElementKey] ASC,
	[SelectedDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FCRecentSelection] ADD  CONSTRAINT [DF_FCRecentSelection_UsedAsAIContext]  DEFAULT ((0)) FOR [UsedAsAIContext]
GO
ALTER TABLE [dbo].[FCRecentSelection]  WITH CHECK ADD  CONSTRAINT [FK_FCRecentSelection_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCRecentSelection] CHECK CONSTRAINT [FK_FCRecentSelection_Company]
GO
ALTER TABLE [dbo].[FCRecentSelection]  WITH CHECK ADD  CONSTRAINT [FK_FCRecentSelection_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCRecentSelection] CHECK CONSTRAINT [FK_FCRecentSelection_FCType]
GO
ALTER TABLE [dbo].[FCRecentSelection]  WITH CHECK ADD  CONSTRAINT [FK_FCRecentSelection_RunningAsUser] FOREIGN KEY([RunningAsUserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCRecentSelection] CHECK CONSTRAINT [FK_FCRecentSelection_RunningAsUser]
GO
ALTER TABLE [dbo].[FCRecentSelection]  WITH CHECK ADD  CONSTRAINT [FK_FCRecentSelection_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCRecentSelection] CHECK CONSTRAINT [FK_FCRecentSelection_UserSecurityGroup]
GO
