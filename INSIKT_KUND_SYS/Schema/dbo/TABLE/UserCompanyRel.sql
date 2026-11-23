SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserCompanyRel](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[isDefault] [bit] NULL,
 CONSTRAINT [PK_UserCompanyRel] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserCompanyRel]  WITH CHECK ADD  CONSTRAINT [FK_UserCompanyRel_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[UserCompanyRel] CHECK CONSTRAINT [FK_UserCompanyRel_Company]
GO
ALTER TABLE [dbo].[UserCompanyRel]  WITH CHECK ADD  CONSTRAINT [FK_UserCompanyRel_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserCompanyRel] CHECK CONSTRAINT [FK_UserCompanyRel_UserSecurityGroup]
GO
