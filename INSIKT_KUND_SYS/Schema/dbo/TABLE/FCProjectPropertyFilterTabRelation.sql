SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectPropertyFilterTabRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectPropertyFilterID] [int] NOT NULL,
	[FCTypeID] [int] NULL,
	[FCDashboardID] [int] NULL,
	[FCObjectTypeID] [int] NULL,
 CONSTRAINT [PK_FCProjectPropertyFilterTabRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectPropertyFilterTabRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFilterTabRelation_FCDashboard] FOREIGN KEY([FCDashboardID])
REFERENCES [dbo].[FCDashboard] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterTabRelation] CHECK CONSTRAINT [FK_FCProjectPropertyFilterTabRelation_FCDashboard]
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterTabRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFilterTabRelation_FCObjectType] FOREIGN KEY([FCObjectTypeID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterTabRelation] CHECK CONSTRAINT [FK_FCProjectPropertyFilterTabRelation_FCObjectType]
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterTabRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFilterTabRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterTabRelation] CHECK CONSTRAINT [FK_FCProjectPropertyFilterTabRelation_FCType]
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterTabRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFilterTabRelation_Filter] FOREIGN KEY([FCProjectPropertyFilterID])
REFERENCES [dbo].[FCProjectPropertyFilter] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterTabRelation] CHECK CONSTRAINT [FK_FCProjectPropertyFilterTabRelation_Filter]
GO
