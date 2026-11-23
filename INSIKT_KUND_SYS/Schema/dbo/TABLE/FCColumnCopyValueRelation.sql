SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCColumnCopyValueRelation](
	[FromFCColumnID] [int] NOT NULL,
	[ToFCColumnID] [int] NOT NULL,
	[UseParameters] [bit] NOT NULL,
 CONSTRAINT [PK_FCColumnCopyValueRelation] PRIMARY KEY CLUSTERED 
(
	[FromFCColumnID] ASC,
	[ToFCColumnID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCColumnCopyValueRelation] ADD  CONSTRAINT [DF_FCColumnCopyValueRelation_UseParameters]  DEFAULT ((0)) FOR [UseParameters]
GO
ALTER TABLE [dbo].[FCColumnCopyValueRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCColumnCopyValueRelation_FCColumns_From] FOREIGN KEY([FromFCColumnID])
REFERENCES [dbo].[FCColumns] ([ID])
GO
ALTER TABLE [dbo].[FCColumnCopyValueRelation] CHECK CONSTRAINT [FK_FCColumnCopyValueRelation_FCColumns_From]
GO
ALTER TABLE [dbo].[FCColumnCopyValueRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCColumnCopyValueRelation_FCColumns_To] FOREIGN KEY([ToFCColumnID])
REFERENCES [dbo].[FCColumns] ([ID])
GO
ALTER TABLE [dbo].[FCColumnCopyValueRelation] CHECK CONSTRAINT [FK_FCColumnCopyValueRelation_FCColumns_To]
GO
