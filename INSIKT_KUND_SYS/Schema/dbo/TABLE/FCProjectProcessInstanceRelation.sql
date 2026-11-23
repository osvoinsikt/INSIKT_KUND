SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectProcessInstanceRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectID] [int] NOT NULL,
	[ProcessInstanceID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectProcessInstanceRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_FCProjectProcessInstanceRelation_FCProjectID] ON [dbo].[FCProjectProcessInstanceRelation]
(
	[FCProjectID] ASC
)
INCLUDE([ProcessInstanceID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FCProjectProcessInstanceRelation_ProcessInstanceId] ON [dbo].[FCProjectProcessInstanceRelation]
(
	[ProcessInstanceID] ASC
)
INCLUDE([FCProjectID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProcessInstanceRelation_FCProject] FOREIGN KEY([FCProjectID])
REFERENCES [dbo].[FCProject] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceRelation] CHECK CONSTRAINT [FK_FCProjectProcessInstanceRelation_FCProject]
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProcessInstanceRelation_Process] FOREIGN KEY([ProcessInstanceID])
REFERENCES [process].[ProcessInstance] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProcessInstanceRelation] CHECK CONSTRAINT [FK_FCProjectProcessInstanceRelation_Process]
GO
