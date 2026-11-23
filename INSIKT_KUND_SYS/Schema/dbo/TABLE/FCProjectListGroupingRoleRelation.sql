SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectListGroupingRoleRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectListGroupingID] [int] NOT NULL,
	[RoleID] [int] NOT NULL,
 CONSTRAINT [PK_FCProjectListGroupingRoleRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectListGroupingRoleRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectListGroupingRoleRelation_FCProjectListGrouping] FOREIGN KEY([FCProjectListGroupingID])
REFERENCES [dbo].[FCProjectListGrouping] ([ID])
GO
ALTER TABLE [dbo].[FCProjectListGroupingRoleRelation] CHECK CONSTRAINT [FK_FCProjectListGroupingRoleRelation_FCProjectListGrouping]
GO
ALTER TABLE [dbo].[FCProjectListGroupingRoleRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectListGroupingRoleRelation_Role] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Role] ([ID])
GO
ALTER TABLE [dbo].[FCProjectListGroupingRoleRelation] CHECK CONSTRAINT [FK_FCProjectListGroupingRoleRelation_Role]
GO
