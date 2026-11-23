SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[RoleTaskRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RoleID] [int] NOT NULL,
	[TaskID] [int] NOT NULL,
	[HierarchyID] [int] NULL,
 CONSTRAINT [PK_app_RoleTaskRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [app].[RoleTaskRelation]  WITH CHECK ADD  CONSTRAINT [FK_dw_RoleTaskRelation_Hierarchy] FOREIGN KEY([HierarchyID])
REFERENCES [app].[Hierarchy] ([HierarchyID])
GO
ALTER TABLE [app].[RoleTaskRelation] CHECK CONSTRAINT [FK_dw_RoleTaskRelation_Hierarchy]
GO
ALTER TABLE [app].[RoleTaskRelation]  WITH CHECK ADD  CONSTRAINT [FK_dw_RoleTaskRelation_Task] FOREIGN KEY([TaskID])
REFERENCES [app].[Task] ([ID])
GO
ALTER TABLE [app].[RoleTaskRelation] CHECK CONSTRAINT [FK_dw_RoleTaskRelation_Task]
GO
