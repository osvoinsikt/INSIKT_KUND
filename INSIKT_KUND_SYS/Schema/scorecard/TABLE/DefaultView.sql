SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[DefaultView](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrganisationMemberID] [int] NOT NULL,
	[HideActivityLevel] [bit] NOT NULL,
	[ModelTypeID] [int] NOT NULL,
 CONSTRAINT [PK_Scorecard_DefaultView] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [scorecard].[DefaultView]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_DefaultView_ModelTypeID] FOREIGN KEY([ModelTypeID])
REFERENCES [scorecard].[ModelType] ([ID])
GO
ALTER TABLE [scorecard].[DefaultView] CHECK CONSTRAINT [FK_Scorecard_DefaultView_ModelTypeID]
GO
ALTER TABLE [scorecard].[DefaultView]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_DefaultView_OrganisationMemberID] FOREIGN KEY([OrganisationMemberID])
REFERENCES [scorecard].[OrganisationMember] ([ID])
GO
ALTER TABLE [scorecard].[DefaultView] CHECK CONSTRAINT [FK_Scorecard_DefaultView_OrganisationMemberID]
GO
