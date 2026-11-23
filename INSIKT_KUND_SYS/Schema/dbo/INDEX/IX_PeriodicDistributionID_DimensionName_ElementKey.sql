CREATE NONCLUSTERED INDEX [IX_PeriodicDistributionID_DimensionName_ElementKey] ON [dbo].[FCElementPeriodicDistributionDimension]
(
	[PeriodicDistributionID] ASC
)
INCLUDE([DimensionName],[ElementKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
