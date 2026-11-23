SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[ProcessComment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL,
	[OrganisationMemberID] [int] NOT NULL,
	[ModelTypeID] [int] NOT NULL,
	[StatusTypeID] [int] NOT NULL,
	[Comment] [nvarchar](max) NULL,
	[ModifiedBy] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Scorecard_ProcessComment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Scorecard_ProcessComment_Active] ON [scorecard].[ProcessComment]
(
	[VersionID] ASC,
	[OrganisationMemberID] ASC,
	[ModelTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [scorecard].[ProcessComment]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ProcessComment_ModelType] FOREIGN KEY([ModelTypeID])
REFERENCES [scorecard].[ModelType] ([ID])
GO
ALTER TABLE [scorecard].[ProcessComment] CHECK CONSTRAINT [FK_Scorecard_ProcessComment_ModelType]
GO
ALTER TABLE [scorecard].[ProcessComment]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ProcessComment_OrganisationMember] FOREIGN KEY([OrganisationMemberID])
REFERENCES [scorecard].[OrganisationMember] ([ID])
GO
ALTER TABLE [scorecard].[ProcessComment] CHECK CONSTRAINT [FK_Scorecard_ProcessComment_OrganisationMember]
GO
ALTER TABLE [scorecard].[ProcessComment]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ProcessComment_StatusType] FOREIGN KEY([StatusTypeID])
REFERENCES [scorecard].[ProcessCommentStatusType] ([ID])
GO
ALTER TABLE [scorecard].[ProcessComment] CHECK CONSTRAINT [FK_Scorecard_ProcessComment_StatusType]
GO
ALTER TABLE [scorecard].[ProcessComment]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ProcessComment_UserSecurityGroup_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[ProcessComment] CHECK CONSTRAINT [FK_Scorecard_ProcessComment_UserSecurityGroup_ModifiedBy]
GO
ALTER TABLE [scorecard].[ProcessComment]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ProcessComment_Version] FOREIGN KEY([VersionID])
REFERENCES [scorecard].[Version] ([ID])
GO
ALTER TABLE [scorecard].[ProcessComment] CHECK CONSTRAINT [FK_Scorecard_ProcessComment_Version]
GO
