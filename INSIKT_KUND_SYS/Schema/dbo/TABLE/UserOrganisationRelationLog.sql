SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserOrganisationRelationLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InitiatedBy] [int] NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[TypeID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[FCRoleID] [int] NOT NULL,
	[ElementKey] [nvarchar](50) NOT NULL,
	[FCMainDimensionMember] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_UserOrganisationRelationLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserOrganisationRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_UserOrganisationRelationLog_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[UserOrganisationRelationLog] CHECK CONSTRAINT [FK_UserOrganisationRelationLog_Company]
GO
ALTER TABLE [dbo].[UserOrganisationRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_UserOrganisationRelationLog_FCRole] FOREIGN KEY([FCRoleID])
REFERENCES [dbo].[FCRole] ([ID])
GO
ALTER TABLE [dbo].[UserOrganisationRelationLog] CHECK CONSTRAINT [FK_UserOrganisationRelationLog_FCRole]
GO
ALTER TABLE [dbo].[UserOrganisationRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_UserOrganisationRelationLog_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[UserOrganisationRelationLog] CHECK CONSTRAINT [FK_UserOrganisationRelationLog_FCType]
GO
ALTER TABLE [dbo].[UserOrganisationRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_UserOrganisationRelationLog_InitiatedBy_UserSecurityGroup] FOREIGN KEY([InitiatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserOrganisationRelationLog] CHECK CONSTRAINT [FK_UserOrganisationRelationLog_InitiatedBy_UserSecurityGroup]
GO
ALTER TABLE [dbo].[UserOrganisationRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_UserOrganisationRelationLog_UserID_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserOrganisationRelationLog] CHECK CONSTRAINT [FK_UserOrganisationRelationLog_UserID_UserSecurityGroup]
GO
ALTER TABLE [dbo].[UserOrganisationRelationLog]  WITH CHECK ADD  CONSTRAINT [FK_UserOrganisationRelationLog_UserOrganisationRelationLogType] FOREIGN KEY([TypeID])
REFERENCES [dbo].[UserOrganisationRelationLogType] ([ID])
GO
ALTER TABLE [dbo].[UserOrganisationRelationLog] CHECK CONSTRAINT [FK_UserOrganisationRelationLog_UserOrganisationRelationLogType]
GO
