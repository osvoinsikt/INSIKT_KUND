SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[Process](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL,
	[OrganisationMemberID] [int] NOT NULL,
	[FinishedDate] [datetime] NULL,
	[FinishedBy] [int] NULL,
	[ModelTypeID] [int] NOT NULL,
 CONSTRAINT [PK_Scorecard_Process] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [scorecard].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Process_FinishedBy] FOREIGN KEY([FinishedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[Process] CHECK CONSTRAINT [FK_Scorecard_Process_FinishedBy]
GO
ALTER TABLE [scorecard].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Process_ModelTypeID] FOREIGN KEY([ModelTypeID])
REFERENCES [scorecard].[ModelType] ([ID])
GO
ALTER TABLE [scorecard].[Process] CHECK CONSTRAINT [FK_Scorecard_Process_ModelTypeID]
GO
ALTER TABLE [scorecard].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Process_OrganisationMemberID] FOREIGN KEY([OrganisationMemberID])
REFERENCES [scorecard].[OrganisationMember] ([ID])
GO
ALTER TABLE [scorecard].[Process] CHECK CONSTRAINT [FK_Scorecard_Process_OrganisationMemberID]
GO
ALTER TABLE [scorecard].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Process_VersionID] FOREIGN KEY([VersionID])
REFERENCES [scorecard].[Version] ([ID])
GO
ALTER TABLE [scorecard].[Process] CHECK CONSTRAINT [FK_Scorecard_Process_VersionID]
GO
