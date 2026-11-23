SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCCategoryFCTypeGroupRelation](
	[FCCategoryID] [int] NOT NULL,
	[FCTypeGroupID] [int] NOT NULL,
 CONSTRAINT [PK_FCCategoryFCTypeGroupRelation] PRIMARY KEY CLUSTERED 
(
	[FCCategoryID] ASC,
	[FCTypeGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCCategoryFCTypeGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCCategoryFCTypeGroupRelation_FCCategory] FOREIGN KEY([FCCategoryID])
REFERENCES [dbo].[FCCategory] ([ID])
GO
ALTER TABLE [dbo].[FCCategoryFCTypeGroupRelation] CHECK CONSTRAINT [FK_FCCategoryFCTypeGroupRelation_FCCategory]
GO
ALTER TABLE [dbo].[FCCategoryFCTypeGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCCategoryFCTypeGroupRelation_FCTypeGroup] FOREIGN KEY([FCTypeGroupID])
REFERENCES [dbo].[FCTypeGroup] ([ID])
GO
ALTER TABLE [dbo].[FCCategoryFCTypeGroupRelation] CHECK CONSTRAINT [FK_FCCategoryFCTypeGroupRelation_FCTypeGroup]
GO
