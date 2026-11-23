SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [process].[ProcessTemplatePhaseRevision](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessTemplatePhaseID] [int] NOT NULL,
	[ProcessTemplateRevisionID] [int] NOT NULL,
	[MainDecisionPointActivityID] [int] NOT NULL,
	[Order] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_ProcessTemplatePhaseRevision] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [process].[ProcessTemplatePhaseRevision] ADD  CONSTRAINT [DF_ProcessTemplatePhaseRevision_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [process].[ProcessTemplatePhaseRevision]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTemplatePhaseRevision_ProcessTemplatePhase] FOREIGN KEY([ProcessTemplatePhaseID])
REFERENCES [process].[ProcessTemplatePhase] ([ID])
GO
ALTER TABLE [process].[ProcessTemplatePhaseRevision] CHECK CONSTRAINT [FK_ProcessTemplatePhaseRevision_ProcessTemplatePhase]
GO
ALTER TABLE [process].[ProcessTemplatePhaseRevision]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTemplatePhaseRevision_ProcessTemplateRevision] FOREIGN KEY([ProcessTemplateRevisionID])
REFERENCES [process].[ProcessTemplateRevision] ([ID])
GO
ALTER TABLE [process].[ProcessTemplatePhaseRevision] CHECK CONSTRAINT [FK_ProcessTemplatePhaseRevision_ProcessTemplateRevision]
GO
