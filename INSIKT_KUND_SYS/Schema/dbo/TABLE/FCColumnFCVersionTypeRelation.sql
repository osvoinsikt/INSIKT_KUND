SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCColumnFCVersionTypeRelation](
	[FCColumnID] [int] NOT NULL,
	[FCVersionTypeID] [int] NOT NULL,
 CONSTRAINT [PK_FCColumnFCVersionTypeRelation] PRIMARY KEY CLUSTERED 
(
	[FCColumnID] ASC,
	[FCVersionTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCColumnFCVersionTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCColumnFCVersionTypeRelation_FCColumns] FOREIGN KEY([FCColumnID])
REFERENCES [dbo].[FCColumns] ([ID])
GO
ALTER TABLE [dbo].[FCColumnFCVersionTypeRelation] CHECK CONSTRAINT [FK_FCColumnFCVersionTypeRelation_FCColumns]
GO
ALTER TABLE [dbo].[FCColumnFCVersionTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCColumnFCVersionTypeRelation_FCVersionType] FOREIGN KEY([FCVersionTypeID])
REFERENCES [dbo].[FCVersionType] ([ID])
GO
ALTER TABLE [dbo].[FCColumnFCVersionTypeRelation] CHECK CONSTRAINT [FK_FCColumnFCVersionTypeRelation_FCVersionType]
GO
