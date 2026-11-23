SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCDimensionAncestorRelation](
	[AncestorID] [int] NOT NULL,
	[DecendantID] [int] NOT NULL,
 CONSTRAINT [PK_FCDimensionAncestorRelation] PRIMARY KEY CLUSTERED 
(
	[AncestorID] ASC,
	[DecendantID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCDimensionAncestorRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCDimensionAncestorRelation_FCDimension] FOREIGN KEY([AncestorID])
REFERENCES [dbo].[FCDimension] ([ID])
GO
ALTER TABLE [dbo].[FCDimensionAncestorRelation] CHECK CONSTRAINT [FK_FCDimensionAncestorRelation_FCDimension]
GO
ALTER TABLE [dbo].[FCDimensionAncestorRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCDimensionAncestorRelation_FCDimension1] FOREIGN KEY([DecendantID])
REFERENCES [dbo].[FCDimension] ([ID])
GO
ALTER TABLE [dbo].[FCDimensionAncestorRelation] CHECK CONSTRAINT [FK_FCDimensionAncestorRelation_FCDimension1]
GO
