SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCProjectPropertyFilterValue](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectPropertyFilterPartID] [int] NOT NULL,
	[FCProjectPropertyID] [int] NOT NULL,
	[ValueNumeric] [float] NULL,
	[ValueString] [varchar](3000) NULL,
	[FCProjectPropertyPredefinedValueID] [int] NULL,
 CONSTRAINT [PK_FCProjectPropertyFilterValue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterValue]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFilterValue_FCProjectProperty] FOREIGN KEY([FCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterValue] CHECK CONSTRAINT [FK_FCProjectPropertyFilterValue_FCProjectProperty]
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterValue]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFilterValue_FCProjectPropertyFilterPart] FOREIGN KEY([FCProjectPropertyFilterPartID])
REFERENCES [dbo].[FCProjectPropertyFilterPart] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterValue] CHECK CONSTRAINT [FK_FCProjectPropertyFilterValue_FCProjectPropertyFilterPart]
GO
