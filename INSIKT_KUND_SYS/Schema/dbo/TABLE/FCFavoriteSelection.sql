SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCFavoriteSelection](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[ElementKey] [nvarchar](255) NOT NULL,
	[Caption] [nvarchar](max) NOT NULL,
	[ViewMode] [int] NULL,
	[UserID] [int] NOT NULL,
 CONSTRAINT [PK_FCFavoriteSelection] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCFavoriteSelection]  WITH CHECK ADD  CONSTRAINT [FK_FCFavoriteSelection_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCFavoriteSelection] CHECK CONSTRAINT [FK_FCFavoriteSelection_Company]
GO
ALTER TABLE [dbo].[FCFavoriteSelection]  WITH CHECK ADD  CONSTRAINT [FK_FCFavoriteSelection_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCFavoriteSelection] CHECK CONSTRAINT [FK_FCFavoriteSelection_FCType]
GO
ALTER TABLE [dbo].[FCFavoriteSelection]  WITH CHECK ADD  CONSTRAINT [FK_FCFavoriteSelection_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCFavoriteSelection] CHECK CONSTRAINT [FK_FCFavoriteSelection_UserSecurityGroup]
GO
