SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCElementPeriodicDistributionDimension](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PeriodicDistributionID] [int] NOT NULL,
	[DimensionName] [nvarchar](50) NOT NULL,
	[ElementKey] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_FCElementPeriodicDistributionDimension] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
CREATE UNIQUE CLUSTERED INDEX [IX_DimensionName_ElementKey_PeriodicDistributionID] ON [dbo].[FCElementPeriodicDistributionDimension]
(
	[DimensionName] ASC,
	[ElementKey] ASC,
	[PeriodicDistributionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PeriodicDistributionID_DimensionName_ElementKey] ON [dbo].[FCElementPeriodicDistributionDimension]
(
	[PeriodicDistributionID] ASC
)
INCLUDE([DimensionName],[ElementKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FCElementPeriodicDistributionDimension]  WITH CHECK ADD  CONSTRAINT [FK_FCElementPeriodicDistributionDimension_FCElementPeriodicDistribution] FOREIGN KEY([PeriodicDistributionID])
REFERENCES [dbo].[FCElementPeriodicDistribution] ([ID])
GO
ALTER TABLE [dbo].[FCElementPeriodicDistributionDimension] CHECK CONSTRAINT [FK_FCElementPeriodicDistributionDimension_FCElementPeriodicDistribution]
GO
