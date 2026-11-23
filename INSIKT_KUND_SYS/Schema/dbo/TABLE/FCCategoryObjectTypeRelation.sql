SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCCategoryObjectTypeRelation](
	[FCCategoryID] [int] NOT NULL,
	[FCObjectTypeID] [int] NOT NULL,
 CONSTRAINT [PK_FCCategoryObjectTypeRelation_1] PRIMARY KEY CLUSTERED 
(
	[FCCategoryID] ASC,
	[FCObjectTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCCategoryObjectTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCCategoryObjectTypeRelation_FCCategory] FOREIGN KEY([FCCategoryID])
REFERENCES [dbo].[FCCategory] ([ID])
GO
ALTER TABLE [dbo].[FCCategoryObjectTypeRelation] CHECK CONSTRAINT [FK_FCCategoryObjectTypeRelation_FCCategory]
GO
ALTER TABLE [dbo].[FCCategoryObjectTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCCategoryObjectTypeRelation_FCObjectType] FOREIGN KEY([FCObjectTypeID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[FCCategoryObjectTypeRelation] CHECK CONSTRAINT [FK_FCCategoryObjectTypeRelation_FCObjectType]
GO
