SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectPropertyFilterValue](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyFilterID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[Value] [nvarchar](3000) NULL,
 CONSTRAINT [PK_FCObjectPropertyFilterValue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCObjectPropertyFilterValue]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectPropertyFilterValue_Property] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[FCObjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCObjectPropertyFilterValue] CHECK CONSTRAINT [FK_FCObjectPropertyFilterValue_Property]
GO
ALTER TABLE [dbo].[FCObjectPropertyFilterValue]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectPropertyFilterValue_PropertyFilter] FOREIGN KEY([PropertyFilterID])
REFERENCES [dbo].[FCObjectPropertyFilter] ([ID])
GO
ALTER TABLE [dbo].[FCObjectPropertyFilterValue] CHECK CONSTRAINT [FK_FCObjectPropertyFilterValue_PropertyFilter]
GO
