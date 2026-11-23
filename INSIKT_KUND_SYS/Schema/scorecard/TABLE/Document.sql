SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[Document](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DocumentID] [int] NOT NULL,
	[ModelTypeID] [int] NOT NULL,
	[VersionID] [int] NOT NULL,
	[OrganisationMemberID] [int] NULL,
	[GoalID] [int] NULL,
	[ActivityID] [int] NULL,
	[KPIID] [int] NULL,
 CONSTRAINT [PK_Scorecard_Document] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [scorecard].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Document_ActivityID] FOREIGN KEY([ActivityID])
REFERENCES [scorecard].[Activity] ([ID])
GO
ALTER TABLE [scorecard].[Document] CHECK CONSTRAINT [FK_Scorecard_Document_ActivityID]
GO
ALTER TABLE [scorecard].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Document_DocumentID] FOREIGN KEY([DocumentID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [scorecard].[Document] CHECK CONSTRAINT [FK_Scorecard_Document_DocumentID]
GO
ALTER TABLE [scorecard].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Document_GoalID] FOREIGN KEY([GoalID])
REFERENCES [scorecard].[Goal] ([ID])
GO
ALTER TABLE [scorecard].[Document] CHECK CONSTRAINT [FK_Scorecard_Document_GoalID]
GO
ALTER TABLE [scorecard].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Document_KPIID] FOREIGN KEY([KPIID])
REFERENCES [scorecard].[KPI] ([ID])
GO
ALTER TABLE [scorecard].[Document] CHECK CONSTRAINT [FK_Scorecard_Document_KPIID]
GO
ALTER TABLE [scorecard].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Document_ModelTypeID] FOREIGN KEY([ModelTypeID])
REFERENCES [scorecard].[ModelType] ([ID])
GO
ALTER TABLE [scorecard].[Document] CHECK CONSTRAINT [FK_Scorecard_Document_ModelTypeID]
GO
ALTER TABLE [scorecard].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Document_OrganisationMemberID] FOREIGN KEY([OrganisationMemberID])
REFERENCES [scorecard].[OrganisationMember] ([ID])
GO
ALTER TABLE [scorecard].[Document] CHECK CONSTRAINT [FK_Scorecard_Document_OrganisationMemberID]
GO
ALTER TABLE [scorecard].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Document_VersionID] FOREIGN KEY([VersionID])
REFERENCES [scorecard].[Version] ([ID])
GO
ALTER TABLE [scorecard].[Document] CHECK CONSTRAINT [FK_Scorecard_Document_VersionID]
GO
