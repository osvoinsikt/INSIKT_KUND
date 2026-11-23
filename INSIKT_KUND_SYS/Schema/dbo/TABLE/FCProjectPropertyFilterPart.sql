SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectPropertyFilterPart](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectPropertyFilterID] [int] NOT NULL,
	[Operator] [int] NOT NULL,
	[ParentFCProjectPropertyFilterPartID] [int] NULL,
 CONSTRAINT [PK_FCProjectPropertyFilterPart] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectPropertyFilterPart]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFilterPart_FCProjectPropertyFilter] FOREIGN KEY([FCProjectPropertyFilterID])
REFERENCES [dbo].[FCProjectPropertyFilter] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterPart] CHECK CONSTRAINT [FK_FCProjectPropertyFilterPart_FCProjectPropertyFilter]
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterPart]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFilterPart_FCProjectPropertyFilterPart] FOREIGN KEY([ParentFCProjectPropertyFilterPartID])
REFERENCES [dbo].[FCProjectPropertyFilterPart] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterPart] CHECK CONSTRAINT [FK_FCProjectPropertyFilterPart_FCProjectPropertyFilterPart]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1= AND 2= OR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCProjectPropertyFilterPart', @level2type=N'COLUMN',@level2name=N'Operator'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Stöd för nestade filter' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCProjectPropertyFilterPart', @level2type=N'COLUMN',@level2name=N'ParentFCProjectPropertyFilterPartID'
GO
