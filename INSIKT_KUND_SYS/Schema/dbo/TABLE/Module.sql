SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Module](
	[ID] [int] NOT NULL,
	[Caption] [nvarchar](30) NOT NULL,
	[Icon] [nvarchar](50) NULL,
	[SortOrder] [int] NOT NULL,
	[ModuleGroupID] [int] NOT NULL,
	[SystemModuleID] [int] NOT NULL,
	[URL] [nvarchar](2083) NULL,
	[OpenInNewFrame] [bit] NOT NULL,
	[ProjectPortfolioCategoryID] [int] NULL,
 CONSTRAINT [PK_Module] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Module] ADD  CONSTRAINT [DF_Module_OpenInNewFrame]  DEFAULT ((0)) FOR [OpenInNewFrame]
GO
ALTER TABLE [dbo].[Module]  WITH CHECK ADD  CONSTRAINT [FK_Module_ProjectPortfolioCategory] FOREIGN KEY([ProjectPortfolioCategoryID])
REFERENCES [dbo].[Category] ([ID])
GO
ALTER TABLE [dbo].[Module] CHECK CONSTRAINT [FK_Module_ProjectPortfolioCategory]
GO
ALTER TABLE [dbo].[Module]  WITH CHECK ADD  CONSTRAINT [FK_ModuleGroup_Module] FOREIGN KEY([ModuleGroupID])
REFERENCES [dbo].[ModuleGroup] ([ID])
GO
ALTER TABLE [dbo].[Module] CHECK CONSTRAINT [FK_ModuleGroup_Module]
GO
ALTER TABLE [dbo].[Module]  WITH CHECK ADD  CONSTRAINT [FK_SystemModules_Module] FOREIGN KEY([SystemModuleID])
REFERENCES [dbo].[SystemModules] ([ID])
GO
ALTER TABLE [dbo].[Module] CHECK CONSTRAINT [FK_SystemModules_Module]
GO
