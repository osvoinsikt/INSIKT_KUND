SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [process].[ProcessInstancePhase](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessTemplatePhaseRevisionID] [int] NOT NULL,
	[ProcessInstanceID] [int] NOT NULL,
	[IsFinished] [bit] NOT NULL,
	[Order] [int] NOT NULL,
 CONSTRAINT [PK_ProcessInstancePhase] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE UNIQUE CLUSTERED INDEX [IX_ProcessInstancePhase_ProcessInstanceID] ON [process].[ProcessInstancePhase]
(
	[ProcessInstanceID] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProcessInstancePhase_ID] ON [process].[ProcessInstancePhase]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [process].[ProcessInstancePhase] ADD  CONSTRAINT [DF_ProcessPhaseInstance_IsFinished]  DEFAULT ((0)) FOR [IsFinished]
GO
ALTER TABLE [process].[ProcessInstancePhase]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstancePhase_ProcessInstance] FOREIGN KEY([ProcessInstanceID])
REFERENCES [process].[ProcessInstance] ([ID])
GO
ALTER TABLE [process].[ProcessInstancePhase] CHECK CONSTRAINT [FK_ProcessInstancePhase_ProcessInstance]
GO
ALTER TABLE [process].[ProcessInstancePhase]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstancePhase_ProcessTemplatePhaseRevision] FOREIGN KEY([ProcessTemplatePhaseRevisionID])
REFERENCES [process].[ProcessTemplatePhaseRevision] ([ID])
GO
ALTER TABLE [process].[ProcessInstancePhase] CHECK CONSTRAINT [FK_ProcessInstancePhase_ProcessTemplatePhaseRevision]
GO
