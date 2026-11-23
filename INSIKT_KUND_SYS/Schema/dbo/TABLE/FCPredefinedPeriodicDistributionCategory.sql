SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCPredefinedPeriodicDistributionCategory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](500) NOT NULL,
	[ParentCategoryID] [int] NULL,
	[UserID] [int] NULL,
	[IsCommon] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_FCPredefinedPeriodicDistributionCategory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistributionCategory]  WITH CHECK ADD  CONSTRAINT [FK_FCPredefinedPeriodicDistributionCategory_Parent] FOREIGN KEY([ParentCategoryID])
REFERENCES [dbo].[FCPredefinedPeriodicDistributionCategory] ([ID])
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistributionCategory] CHECK CONSTRAINT [FK_FCPredefinedPeriodicDistributionCategory_Parent]
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistributionCategory]  WITH CHECK ADD  CONSTRAINT [FK_FCPredefinedPeriodicDistributionCategory_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistributionCategory] CHECK CONSTRAINT [FK_FCPredefinedPeriodicDistributionCategory_User]
GO
