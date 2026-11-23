SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [integration].[CustomDomainUserGroupRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserAccountName] [nvarchar](255) NOT NULL,
	[GroupAccountName] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_CustomDomainUserGroupRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [integration].[CustomDomainUserGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_CustomDomainUserGroupRelationGroupAccountName] FOREIGN KEY([GroupAccountName])
REFERENCES [integration].[CustomDomainGroup] ([AccountName])
GO
ALTER TABLE [integration].[CustomDomainUserGroupRelation] CHECK CONSTRAINT [FK_CustomDomainUserGroupRelationGroupAccountName]
GO
ALTER TABLE [integration].[CustomDomainUserGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_CustomDomainUserGroupRelationUserAccountName] FOREIGN KEY([UserAccountName])
REFERENCES [integration].[CustomDomainUser] ([AccountName])
GO
ALTER TABLE [integration].[CustomDomainUserGroupRelation] CHECK CONSTRAINT [FK_CustomDomainUserGroupRelationUserAccountName]
GO
