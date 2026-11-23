SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [process].[ProcessInstanceActivityResponsibleRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessInstanceActivityID] [int] NOT NULL,
	[ProcessInstanceActivityStepID] [int] NULL,
	[RoleID] [int] NULL,
	[UserID] [int] NULL,
 CONSTRAINT [PK_ProcessInstanceResponsibleRelation] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE UNIQUE CLUSTERED INDEX [IX_ProcessInstanceActivityResponsibleRelation_ProcessInstanceActivityID] ON [process].[ProcessInstanceActivityResponsibleRelation]
(
	[ProcessInstanceActivityID] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProcessInstanceResponsibleRelation_RoleID] ON [process].[ProcessInstanceActivityResponsibleRelation]
(
	[RoleID] ASC
)
INCLUDE([ProcessInstanceActivityID],[ProcessInstanceActivityStepID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProcessInstanceResponsibleRelation_UserID] ON [process].[ProcessInstanceActivityResponsibleRelation]
(
	[UserID] ASC
)
INCLUDE([ProcessInstanceActivityID],[ProcessInstanceActivityStepID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [process].[ProcessInstanceActivityResponsibleRelation]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstanceResponsibleRelation_ProcessInstanceActivity] FOREIGN KEY([ProcessInstanceActivityID])
REFERENCES [process].[ProcessInstanceActivity] ([ID])
GO
ALTER TABLE [process].[ProcessInstanceActivityResponsibleRelation] CHECK CONSTRAINT [FK_ProcessInstanceResponsibleRelation_ProcessInstanceActivity]
GO
ALTER TABLE [process].[ProcessInstanceActivityResponsibleRelation]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstanceResponsibleRelation_ProcessInstanceActivityStep] FOREIGN KEY([ProcessInstanceActivityStepID])
REFERENCES [process].[ProcessInstanceActivityStep] ([ID])
GO
ALTER TABLE [process].[ProcessInstanceActivityResponsibleRelation] CHECK CONSTRAINT [FK_ProcessInstanceResponsibleRelation_ProcessInstanceActivityStep]
GO
