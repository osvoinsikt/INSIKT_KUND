CREATE NONCLUSTERED INDEX [IX_FCProjectPropertyValue_Project_ProjectProperty] ON [dbo].[FCProjectPropertyValue]
(
	[ProjectID] ASC,
	[ProjectPropertyID] ASC
)
INCLUDE([ValueNumeric],[ValueString],[FCProjectPropertyPredefinedValueID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
