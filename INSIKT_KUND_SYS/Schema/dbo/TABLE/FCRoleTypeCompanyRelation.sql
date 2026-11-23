SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCRoleTypeCompanyRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCRoleID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
 CONSTRAINT [PK_FCRoleTypeCompanyRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCRoleTypeCompanyRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCRoleTypeCompanyRelation_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCRoleTypeCompanyRelation] CHECK CONSTRAINT [FK_FCRoleTypeCompanyRelation_Company]
GO
ALTER TABLE [dbo].[FCRoleTypeCompanyRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCRoleTypeCompanyRelation_FCRole] FOREIGN KEY([FCRoleID])
REFERENCES [dbo].[FCRole] ([ID])
GO
ALTER TABLE [dbo].[FCRoleTypeCompanyRelation] CHECK CONSTRAINT [FK_FCRoleTypeCompanyRelation_FCRole]
GO
ALTER TABLE [dbo].[FCRoleTypeCompanyRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCRoleTypeCompanyRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCRoleTypeCompanyRelation] CHECK CONSTRAINT [FK_FCRoleTypeCompanyRelation_FCType]
GO
