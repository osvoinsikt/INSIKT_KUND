SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[UserOrganisationRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[OrganisationMemberID] [int] NOT NULL,
	[OrganisationRoleID] [int] NOT NULL,
	[ModelTypeID] [int] NOT NULL,
 CONSTRAINT [PK_Scorecard_UserOrganisationRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [scorecard].[UserOrganisationRelation]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_UserOrganisationRelation_Member] FOREIGN KEY([OrganisationMemberID])
REFERENCES [scorecard].[OrganisationMember] ([ID])
GO
ALTER TABLE [scorecard].[UserOrganisationRelation] CHECK CONSTRAINT [FK_Scorecard_UserOrganisationRelation_Member]
GO
ALTER TABLE [scorecard].[UserOrganisationRelation]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_UserOrganisationRelation_ModelTypeID] FOREIGN KEY([ModelTypeID])
REFERENCES [scorecard].[ModelType] ([ID])
GO
ALTER TABLE [scorecard].[UserOrganisationRelation] CHECK CONSTRAINT [FK_Scorecard_UserOrganisationRelation_ModelTypeID]
GO
ALTER TABLE [scorecard].[UserOrganisationRelation]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_UserOrganisationRelation_Role] FOREIGN KEY([OrganisationRoleID])
REFERENCES [scorecard].[OrganisationRole] ([ID])
GO
ALTER TABLE [scorecard].[UserOrganisationRelation] CHECK CONSTRAINT [FK_Scorecard_UserOrganisationRelation_Role]
GO
ALTER TABLE [scorecard].[UserOrganisationRelation]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_UserOrganisationRelation_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[UserOrganisationRelation] CHECK CONSTRAINT [FK_Scorecard_UserOrganisationRelation_User]
GO
