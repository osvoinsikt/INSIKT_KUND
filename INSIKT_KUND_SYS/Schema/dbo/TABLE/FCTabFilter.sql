SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCTabFilter](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCTypeGroupID] [int] NOT NULL,
	[FCTypeID] [int] NULL,
	[FCDashboardID] [int] NULL,
	[FCObjectTypeID] [int] NULL,
	[MainDimensionElementKey] [nvarchar](100) NOT NULL,
	[IncludeMainDimensionDescendants] [bit] NOT NULL,
 CONSTRAINT [PK_FCTabFilter] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCTabFilter] ADD  CONSTRAINT [DF_FCTabFilter_IncludeMainDimensionDescendants]  DEFAULT ((1)) FOR [IncludeMainDimensionDescendants]
GO
ALTER TABLE [dbo].[FCTabFilter]  WITH CHECK ADD  CONSTRAINT [FK_FCTabFilter_FCDashboard] FOREIGN KEY([FCDashboardID])
REFERENCES [dbo].[FCDashboard] ([ID])
GO
ALTER TABLE [dbo].[FCTabFilter] CHECK CONSTRAINT [FK_FCTabFilter_FCDashboard]
GO
ALTER TABLE [dbo].[FCTabFilter]  WITH CHECK ADD  CONSTRAINT [FK_FCTabFilter_FCObjectType] FOREIGN KEY([FCObjectTypeID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[FCTabFilter] CHECK CONSTRAINT [FK_FCTabFilter_FCObjectType]
GO
ALTER TABLE [dbo].[FCTabFilter]  WITH CHECK ADD  CONSTRAINT [FK_FCTabFilter_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCTabFilter] CHECK CONSTRAINT [FK_FCTabFilter_FCType]
GO
ALTER TABLE [dbo].[FCTabFilter]  WITH CHECK ADD  CONSTRAINT [FK_FCTabFilter_FCTypeGroup] FOREIGN KEY([FCTypeGroupID])
REFERENCES [dbo].[FCTypeGroup] ([ID])
GO
ALTER TABLE [dbo].[FCTabFilter] CHECK CONSTRAINT [FK_FCTabFilter_FCTypeGroup]
GO
