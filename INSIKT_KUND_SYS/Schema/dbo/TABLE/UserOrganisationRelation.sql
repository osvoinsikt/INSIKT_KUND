SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserOrganisationRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[RoleID] [int] NOT NULL,
	[FCElementKey] [nvarchar](50) NOT NULL,
	[FCElementGroupingCaption] [varchar](50) NULL,
	[AllBelow] [bit] NULL,
 CONSTRAINT [PK_UserOrganisationRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[UserOrganisationRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserOrganisationRelation_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[UserOrganisationRelation] CHECK CONSTRAINT [FK_UserOrganisationRelation_Company]
GO
ALTER TABLE [dbo].[UserOrganisationRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserOrganisationRelation_FCRole1] FOREIGN KEY([RoleID])
REFERENCES [dbo].[FCRole] ([ID])
GO
ALTER TABLE [dbo].[UserOrganisationRelation] CHECK CONSTRAINT [FK_UserOrganisationRelation_FCRole1]
GO
ALTER TABLE [dbo].[UserOrganisationRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserOrganisationRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[UserOrganisationRelation] CHECK CONSTRAINT [FK_UserOrganisationRelation_FCType]
GO
ALTER TABLE [dbo].[UserOrganisationRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserOrganisationRelation_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserOrganisationRelation] CHECK CONSTRAINT [FK_UserOrganisationRelation_UserSecurityGroup]
GO
