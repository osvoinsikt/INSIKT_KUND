CREATE NONCLUSTERED INDEX [IX_ProcessInstanceResponsibleRelation_RoleID] ON [process].[ProcessInstanceActivityResponsibleRelation]
(
	[RoleID] ASC
)
INCLUDE([ProcessInstanceActivityID],[ProcessInstanceActivityStepID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
