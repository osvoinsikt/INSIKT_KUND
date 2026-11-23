SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserSecurityGroup](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](255) NOT NULL,
	[SID] [varchar](50) NOT NULL,
	[FullName] [nvarchar](255) NOT NULL,
	[EmailAdress] [varchar](255) NULL,
	[LangID] [int] NOT NULL,
	[StartReportID] [int] NULL,
	[DefaultDatasourceID] [int] NULL,
	[UserTypeID] [int] NOT NULL,
	[DefaultSecGroupID] [int] NULL,
	[SuperAdmin] [varchar](max) NULL,
	[Password] [char](60) NULL,
	[AuthenticationType] [int] NOT NULL,
	[TimeZone] [varchar](50) NULL,
	[FirstLoginDate] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
	[DomainID] [int] NULL,
	[DefaultDataSourcePerspectiveID] [int] NULL,
	[FirstDayOfWeek] [int] NOT NULL,
	[AcceptLanguageHeader] [nvarchar](100) NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserSecurityGroup_UserName] ON [dbo].[UserSecurityGroup]
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserSecurityGroup] ADD  CONSTRAINT [DF_User_LangID]  DEFAULT ((2)) FOR [LangID]
GO
ALTER TABLE [dbo].[UserSecurityGroup] ADD  CONSTRAINT [DF_User_UserTypeID]  DEFAULT ((3)) FOR [UserTypeID]
GO
ALTER TABLE [dbo].[UserSecurityGroup] ADD  CONSTRAINT [DF_UserSecurityGroup_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[UserSecurityGroup] ADD  CONSTRAINT [DF_UserSecurityGroup_FirstDayOfWeek]  DEFAULT ((1)) FOR [FirstDayOfWeek]
GO
ALTER TABLE [dbo].[UserSecurityGroup]  WITH CHECK ADD  CONSTRAINT [FK_User_DefaultSecGroupID] FOREIGN KEY([DefaultSecGroupID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroup] CHECK CONSTRAINT [FK_User_DefaultSecGroupID]
GO
ALTER TABLE [dbo].[UserSecurityGroup]  WITH CHECK ADD  CONSTRAINT [FK_User_Language] FOREIGN KEY([LangID])
REFERENCES [dbo].[Language] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroup] CHECK CONSTRAINT [FK_User_Language]
GO
ALTER TABLE [dbo].[UserSecurityGroup]  WITH CHECK ADD  CONSTRAINT [FK_User_UserType] FOREIGN KEY([UserTypeID])
REFERENCES [dbo].[UserType] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroup] CHECK CONSTRAINT [FK_User_UserType]
GO
ALTER TABLE [dbo].[UserSecurityGroup]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroup_DataSourcePerspective] FOREIGN KEY([DefaultDataSourcePerspectiveID])
REFERENCES [dbo].[DataSourcePerspective] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroup] CHECK CONSTRAINT [FK_UserSecurityGroup_DataSourcePerspective]
GO
ALTER TABLE [dbo].[UserSecurityGroup]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroup_DataSources] FOREIGN KEY([DefaultDatasourceID])
REFERENCES [dbo].[DataSources] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroup] CHECK CONSTRAINT [FK_UserSecurityGroup_DataSources]
GO
ALTER TABLE [dbo].[UserSecurityGroup]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroup_Domain] FOREIGN KEY([DomainID])
REFERENCES [dbo].[Domain] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroup] CHECK CONSTRAINT [FK_UserSecurityGroup_Domain]
GO
ALTER TABLE [dbo].[UserSecurityGroup]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroup_Report] FOREIGN KEY([StartReportID])
REFERENCES [dbo].[Report] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroup] CHECK CONSTRAINT [FK_UserSecurityGroup_Report]
GO
ALTER TABLE [dbo].[UserSecurityGroup]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroup_UserSecurityGroupAuthenticationType] FOREIGN KEY([AuthenticationType])
REFERENCES [dbo].[UserSecurityGroupAuthenticationType] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroup] CHECK CONSTRAINT [FK_UserSecurityGroup_UserSecurityGroupAuthenticationType]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [dbo].[TriggerInsertUpdate_UserSecurityGroup_EmailAdress] on [dbo].[UserSecurityGroup]
after insert, update as
begin
	-- Make sure email address is not null for internal users
	if exists (
		select 1 from inserted ins
		where ins.DomainID is null and ins.UserTypeID in (3, 5, 7) and ins.IsDeleted = 0 and ins.EmailAdress is null
	)
	begin
		raiserror('Email address for an internal user cannot be null.', 16, 1);
		rollback transaction
		return
	end

	-- Make sure email address is unique among all internal users
	if exists (
		select 1
		from UserSecurityGroup usg
			inner join inserted ins on rtrim(ltrim(ins.EmailAdress)) = rtrim(ltrim(usg.EmailAdress))
		where ins.DomainID is null and usg.UserID != ins.UserID and usg.EmailAdress is not null and ins.EmailAdress is not null
			and usg.UserTypeID in (3, 5, 7) and ins.UserTypeID in (3, 5, 7) and usg.IsDeleted = 0 and ins.IsDeleted = 0
	)
	begin
		raiserror('Email address must be unique.', 16, 2);
		rollback transaction
		return
	end
end
GO
ALTER TABLE [dbo].[UserSecurityGroup] ENABLE TRIGGER [TriggerInsertUpdate_UserSecurityGroup_EmailAdress]
GO
