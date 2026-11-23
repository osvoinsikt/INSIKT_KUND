SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCTabGroupRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCTabGroupID] [int] NOT NULL,
	[FCTypeID] [int] NULL,
	[FCDashboardID] [int] NULL,
	[FCObjectTypeID] [int] NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_FCTabGroupRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCTabGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCTabGroupRelation_FCDashboard] FOREIGN KEY([FCDashboardID])
REFERENCES [dbo].[FCDashboard] ([ID])
GO
ALTER TABLE [dbo].[FCTabGroupRelation] CHECK CONSTRAINT [FK_FCTabGroupRelation_FCDashboard]
GO
ALTER TABLE [dbo].[FCTabGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCTabGroupRelation_FCObjectType] FOREIGN KEY([FCObjectTypeID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[FCTabGroupRelation] CHECK CONSTRAINT [FK_FCTabGroupRelation_FCObjectType]
GO
ALTER TABLE [dbo].[FCTabGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCTabGroupRelation_FCTabGroup] FOREIGN KEY([FCTabGroupID])
REFERENCES [dbo].[FCTabGroup] ([ID])
GO
ALTER TABLE [dbo].[FCTabGroupRelation] CHECK CONSTRAINT [FK_FCTabGroupRelation_FCTabGroup]
GO
ALTER TABLE [dbo].[FCTabGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCTabGroupRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCTabGroupRelation] CHECK CONSTRAINT [FK_FCTabGroupRelation_FCType]
GO
