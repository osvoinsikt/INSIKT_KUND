SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_app_DbSchemaLog_TargetObjectName_SchemaName_TargetObjectType] ON [app].[DbSchemaLog]
(
	[TargetObjectName] ASC,
	[SchemaName] ASC,
	[TargetObjectType] ASC,
	[Id] ASC
)
INCLUDE([TargetObjectDefinition]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
