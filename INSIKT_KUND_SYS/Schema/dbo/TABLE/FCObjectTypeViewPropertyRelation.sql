SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectTypeViewPropertyRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCObjectTypeViewID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[Level] [int] NOT NULL,
 CONSTRAINT [PK_FCObjectTypeViewPropertyRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCObjectTypeViewPropertyRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectTypeViewPropertyRelation_FCObjectTypeViewID] FOREIGN KEY([FCObjectTypeViewID])
REFERENCES [dbo].[FCObjectTypeView] ([ID])
GO
ALTER TABLE [dbo].[FCObjectTypeViewPropertyRelation] CHECK CONSTRAINT [FK_FCObjectTypeViewPropertyRelation_FCObjectTypeViewID]
GO
ALTER TABLE [dbo].[FCObjectTypeViewPropertyRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectTypeViewPropertyRelation_PropertyID] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[FCObjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCObjectTypeViewPropertyRelation] CHECK CONSTRAINT [FK_FCObjectTypeViewPropertyRelation_PropertyID]
GO
