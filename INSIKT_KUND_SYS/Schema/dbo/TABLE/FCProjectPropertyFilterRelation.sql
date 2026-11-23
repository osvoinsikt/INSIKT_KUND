SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectPropertyFilterRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectPropertyFilterID] [int] NOT NULL,
	[FCProjectPropertyID] [int] NULL,
	[FCProjectPropertyGroupID] [int] NULL,
	[FCProjectCardID] [int] NULL,
 CONSTRAINT [FK_FCProjectPropertyFilterRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectPropertyFilterRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFilterRelation_FCProjectCard] FOREIGN KEY([FCProjectCardID])
REFERENCES [dbo].[FCProjectCard] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterRelation] CHECK CONSTRAINT [FK_FCProjectPropertyFilterRelation_FCProjectCard]
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFilterRelation_Filter] FOREIGN KEY([FCProjectPropertyFilterID])
REFERENCES [dbo].[FCProjectPropertyFilter] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterRelation] CHECK CONSTRAINT [FK_FCProjectPropertyFilterRelation_Filter]
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFilterRelation_Property] FOREIGN KEY([FCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterRelation] CHECK CONSTRAINT [FK_FCProjectPropertyFilterRelation_Property]
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFilterRelation_PropertyGroup] FOREIGN KEY([FCProjectPropertyGroupID])
REFERENCES [dbo].[FCProjectPropertyGroup] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterRelation] CHECK CONSTRAINT [FK_FCProjectPropertyFilterRelation_PropertyGroup]
GO
