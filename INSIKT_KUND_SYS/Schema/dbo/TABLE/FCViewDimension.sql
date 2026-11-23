SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCViewDimension](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCViewID] [int] NOT NULL,
	[DimensionName] [nvarchar](200) NOT NULL,
	[PlacementTypeID] [int] NOT NULL,
	[PlacementSortOrder] [int] NULL,
	[DefaultMember] [nvarchar](500) NULL,
	[DefaultWriteMember] [nvarchar](500) NULL,
	[ModeTypeID] [int] NULL,
	[OnlyLeaves] [bit] NULL,
	[IncludeCalculationMembers] [bit] NULL,
	[SortAlphabetically] [bit] NULL,
	[PreExpanded] [bit] NULL,
	[PreDrillStopLevel] [int] NULL,
	[NonEmptyFilterMember] [nvarchar](500) NULL,
	[DoNotFilterOnQuery] [bit] NULL,
 CONSTRAINT [PK_FCViewDimension] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCViewDimension]  WITH CHECK ADD  CONSTRAINT [FK_FCViewDimension_FCView] FOREIGN KEY([FCViewID])
REFERENCES [dbo].[FCView] ([ID])
GO
ALTER TABLE [dbo].[FCViewDimension] CHECK CONSTRAINT [FK_FCViewDimension_FCView]
GO
ALTER TABLE [dbo].[FCViewDimension]  WITH CHECK ADD  CONSTRAINT [FK_FCViewDimension_FCViewDimensionModeType] FOREIGN KEY([ModeTypeID])
REFERENCES [dbo].[FCViewDimensionModeType] ([ID])
GO
ALTER TABLE [dbo].[FCViewDimension] CHECK CONSTRAINT [FK_FCViewDimension_FCViewDimensionModeType]
GO
ALTER TABLE [dbo].[FCViewDimension]  WITH CHECK ADD  CONSTRAINT [FK_FCViewDimension_PlacementType] FOREIGN KEY([PlacementTypeID])
REFERENCES [dbo].[FCViewDimensionPlacementType] ([ID])
GO
ALTER TABLE [dbo].[FCViewDimension] CHECK CONSTRAINT [FK_FCViewDimension_PlacementType]
GO
