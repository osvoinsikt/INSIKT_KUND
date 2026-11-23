SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[Activity](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Status] [int] NOT NULL,
	[Progress] [int] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ResponsibleUserID] [int] NULL,
	[ModelTypeID] [int] NOT NULL,
	[VersionID] [int] NOT NULL,
	[OrganisationMemberID] [int] NOT NULL,
	[ParentActivityID] [int] NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
	[ExternalKey] [nvarchar](255) NULL,
 CONSTRAINT [PK_Scorecard_Activity] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [scorecard].[Activity] ADD  CONSTRAINT [DF_Scorecard_Activity_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [scorecard].[Activity] ADD  CONSTRAINT [DF_Scorecard_Activity_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [scorecard].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Activity_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[Activity] CHECK CONSTRAINT [FK_Scorecard_Activity_CreatedBy]
GO
ALTER TABLE [scorecard].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Activity_ModelTypeID] FOREIGN KEY([ModelTypeID])
REFERENCES [scorecard].[ModelType] ([ID])
GO
ALTER TABLE [scorecard].[Activity] CHECK CONSTRAINT [FK_Scorecard_Activity_ModelTypeID]
GO
ALTER TABLE [scorecard].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Activity_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[Activity] CHECK CONSTRAINT [FK_Scorecard_Activity_ModifiedBy]
GO
ALTER TABLE [scorecard].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Activity_OrganisationMember] FOREIGN KEY([OrganisationMemberID])
REFERENCES [scorecard].[OrganisationMember] ([ID])
GO
ALTER TABLE [scorecard].[Activity] CHECK CONSTRAINT [FK_Scorecard_Activity_OrganisationMember]
GO
ALTER TABLE [scorecard].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Activity_ParentActivity] FOREIGN KEY([ParentActivityID])
REFERENCES [scorecard].[Activity] ([ID])
GO
ALTER TABLE [scorecard].[Activity] CHECK CONSTRAINT [FK_Scorecard_Activity_ParentActivity]
GO
ALTER TABLE [scorecard].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Activity_Progress] FOREIGN KEY([Progress])
REFERENCES [scorecard].[ActivityProgressType] ([ID])
GO
ALTER TABLE [scorecard].[Activity] CHECK CONSTRAINT [FK_Scorecard_Activity_Progress]
GO
ALTER TABLE [scorecard].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Activity_ResponsibleUser] FOREIGN KEY([ResponsibleUserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[Activity] CHECK CONSTRAINT [FK_Scorecard_Activity_ResponsibleUser]
GO
ALTER TABLE [scorecard].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Activity_Status] FOREIGN KEY([Status])
REFERENCES [scorecard].[ActivityStatusType] ([ID])
GO
ALTER TABLE [scorecard].[Activity] CHECK CONSTRAINT [FK_Scorecard_Activity_Status]
GO
ALTER TABLE [scorecard].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Activity_VersionID] FOREIGN KEY([VersionID])
REFERENCES [scorecard].[Version] ([ID])
GO
ALTER TABLE [scorecard].[Activity] CHECK CONSTRAINT [FK_Scorecard_Activity_VersionID]
GO
