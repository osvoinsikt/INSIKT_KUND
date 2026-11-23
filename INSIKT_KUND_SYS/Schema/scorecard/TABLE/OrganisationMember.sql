SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[OrganisationMember](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrganisationID] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[ParentMemberID] [int] NULL,
	[SortOrder] [int] NULL,
	[ElementKey] [nvarchar](100) NOT NULL,
	[UniqueName] [nvarchar](300) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[IsHidden] [bit] NOT NULL,
 CONSTRAINT [PK_Scorecard_OrganisationMember] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [scorecard].[OrganisationMember] ADD  CONSTRAINT [DF_OrganisationMember_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [scorecard].[OrganisationMember] ADD  CONSTRAINT [DF_OrganisationMember_IsHidden]  DEFAULT ((0)) FOR [IsHidden]
GO
ALTER TABLE [scorecard].[OrganisationMember]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_OrganisationMember_Organisation] FOREIGN KEY([OrganisationID])
REFERENCES [scorecard].[Organisation] ([ID])
GO
ALTER TABLE [scorecard].[OrganisationMember] CHECK CONSTRAINT [FK_Scorecard_OrganisationMember_Organisation]
GO
ALTER TABLE [scorecard].[OrganisationMember]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_OrganisationMember_ParentMember] FOREIGN KEY([ParentMemberID])
REFERENCES [scorecard].[OrganisationMember] ([ID])
GO
ALTER TABLE [scorecard].[OrganisationMember] CHECK CONSTRAINT [FK_Scorecard_OrganisationMember_ParentMember]
GO
