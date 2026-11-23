SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserHierarchyRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[UserHierarchyRelationSetID] [int] NOT NULL,
	[MemberUniqueName] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_UserHierarchyRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserHierarchyRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserHierarchyRelation_UserHierarchyRelationSet] FOREIGN KEY([UserHierarchyRelationSetID])
REFERENCES [dbo].[UserHierarchyRelationSet] ([ID])
GO
ALTER TABLE [dbo].[UserHierarchyRelation] CHECK CONSTRAINT [FK_UserHierarchyRelation_UserHierarchyRelationSet]
GO
ALTER TABLE [dbo].[UserHierarchyRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserHierarchyRelation_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserHierarchyRelation] CHECK CONSTRAINT [FK_UserHierarchyRelation_UserSecurityGroup]
GO
