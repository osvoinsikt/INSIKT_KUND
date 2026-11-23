SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectPropertyFilterViewRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ViewID] [int] NOT NULL,
	[PropertyFilterID] [int] NOT NULL,
 CONSTRAINT [PK_FCObjectPropertyFilterViewRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCObjectPropertyFilterViewRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectPropertyFilterViewRelation_FCObjectPropertyFilter] FOREIGN KEY([PropertyFilterID])
REFERENCES [dbo].[FCObjectPropertyFilter] ([ID])
GO
ALTER TABLE [dbo].[FCObjectPropertyFilterViewRelation] CHECK CONSTRAINT [FK_FCObjectPropertyFilterViewRelation_FCObjectPropertyFilter]
GO
ALTER TABLE [dbo].[FCObjectPropertyFilterViewRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectPropertyFilterViewRelation_FCObjectTypeView] FOREIGN KEY([ViewID])
REFERENCES [dbo].[FCObjectTypeView] ([ID])
GO
ALTER TABLE [dbo].[FCObjectPropertyFilterViewRelation] CHECK CONSTRAINT [FK_FCObjectPropertyFilterViewRelation_FCObjectTypeView]
GO
