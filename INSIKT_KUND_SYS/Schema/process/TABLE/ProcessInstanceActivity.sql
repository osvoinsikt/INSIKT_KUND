SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [process].[ProcessInstanceActivity](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessTemplateActivityRevisionID] [int] NULL,
	[ProcessInstancePhaseID] [int] NOT NULL,
	[Order] [int] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[IsFinished] [bit] NOT NULL,
	[ParentProcessInstanceActivityID] [int] NULL,
	[Name] [nvarchar](255) NULL,
	[Description] [nvarchar](max) NULL,
	[IsHidden] [bit] NOT NULL,
	[IsMandatory] [bit] NOT NULL,
	[ChangeTypeID] [int] NULL,
	[CreatedBy] [int] NULL,
	[NotApplicable] [bit] NOT NULL,
 CONSTRAINT [PK_ProcessActivityInstance] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE UNIQUE CLUSTERED INDEX [IX_ProcessInstanceActivity_ProcessInstancePhaseID] ON [process].[ProcessInstanceActivity]
(
	[ProcessInstancePhaseID] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProcessInstanceActivity_ID] ON [process].[ProcessInstanceActivity]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [process].[ProcessInstanceActivity] ADD  CONSTRAINT [DF_ProcessInstanceActivity_IsFinished]  DEFAULT ((0)) FOR [IsFinished]
GO
ALTER TABLE [process].[ProcessInstanceActivity] ADD  CONSTRAINT [DF_ProcessActivityInstance_IsHidden]  DEFAULT ((0)) FOR [IsHidden]
GO
ALTER TABLE [process].[ProcessInstanceActivity] ADD  CONSTRAINT [DF_ProcessInstanceActivity_IsMandatory]  DEFAULT ((0)) FOR [IsMandatory]
GO
ALTER TABLE [process].[ProcessInstanceActivity] ADD  CONSTRAINT [DF_ProcessInstanceActivity_NotApplicable]  DEFAULT ((0)) FOR [NotApplicable]
GO
ALTER TABLE [process].[ProcessInstanceActivity]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstanceActivity_ProcessInstanceActivity] FOREIGN KEY([ParentProcessInstanceActivityID])
REFERENCES [process].[ProcessInstanceActivity] ([ID])
GO
ALTER TABLE [process].[ProcessInstanceActivity] CHECK CONSTRAINT [FK_ProcessInstanceActivity_ProcessInstanceActivity]
GO
ALTER TABLE [process].[ProcessInstanceActivity]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstanceActivity_ProcessInstancePhase] FOREIGN KEY([ProcessInstancePhaseID])
REFERENCES [process].[ProcessInstancePhase] ([ID])
GO
ALTER TABLE [process].[ProcessInstanceActivity] CHECK CONSTRAINT [FK_ProcessInstanceActivity_ProcessInstancePhase]
GO
ALTER TABLE [process].[ProcessInstanceActivity]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstanceActivity_ProcessRevisionChangeType] FOREIGN KEY([ChangeTypeID])
REFERENCES [process].[ProcessRevisionChangeType] ([ID])
GO
ALTER TABLE [process].[ProcessInstanceActivity] CHECK CONSTRAINT [FK_ProcessInstanceActivity_ProcessRevisionChangeType]
GO
ALTER TABLE [process].[ProcessInstanceActivity]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstanceActivity_ProcessTemplateActivityRevision] FOREIGN KEY([ProcessTemplateActivityRevisionID])
REFERENCES [process].[ProcessTemplateActivityRevision] ([ID])
GO
ALTER TABLE [process].[ProcessInstanceActivity] CHECK CONSTRAINT [FK_ProcessInstanceActivity_ProcessTemplateActivityRevision]
GO
ALTER TABLE [process].[ProcessInstanceActivity]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInstanceActivity_UserSecurityGroup] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [process].[ProcessInstanceActivity] CHECK CONSTRAINT [FK_ProcessInstanceActivity_UserSecurityGroup]
GO
