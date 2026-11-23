SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSecurityGroupImportRelation](
	[ImportID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
 CONSTRAINT [PK_UserSecurityGroupImportRelation] PRIMARY KEY CLUSTERED 
(
	[ImportID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserSecurityGroupImportRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupImportRelation_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroupImportRelation] CHECK CONSTRAINT [FK_UserSecurityGroupImportRelation_UserSecurityGroup]
GO
ALTER TABLE [dbo].[UserSecurityGroupImportRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupImportRelation_UserSecurityGroupImport] FOREIGN KEY([ImportID])
REFERENCES [dbo].[UserSecurityGroupImport] ([ID])
GO
ALTER TABLE [dbo].[UserSecurityGroupImportRelation] CHECK CONSTRAINT [FK_UserSecurityGroupImportRelation_UserSecurityGroupImport]
GO
