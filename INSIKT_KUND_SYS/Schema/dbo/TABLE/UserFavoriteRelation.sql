SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserFavoriteRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[SortOrder] [int] NULL,
	[ReportID] [int] NULL,
 CONSTRAINT [PK_UserFavoriteRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserFavoriteRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserFavoriteRelation_Report] FOREIGN KEY([ReportID])
REFERENCES [dbo].[Report] ([ID])
GO
ALTER TABLE [dbo].[UserFavoriteRelation] CHECK CONSTRAINT [FK_UserFavoriteRelation_Report]
GO
ALTER TABLE [dbo].[UserFavoriteRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserFavoriteRelation_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserFavoriteRelation] CHECK CONSTRAINT [FK_UserFavoriteRelation_UserSecurityGroup]
GO
