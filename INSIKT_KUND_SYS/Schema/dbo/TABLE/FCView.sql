SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCView](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[HideEmpty] [bit] NOT NULL,
	[HideEmptyObligatory] [bit] NULL,
	[ReadOnly] [bit] NOT NULL,
	[ShowRowSum] [bit] NOT NULL,
	[ShowColumnSum] [bit] NOT NULL,
	[EnableGroupingCellWrite] [bit] NOT NULL,
	[GroupingCellDistributionOptionId] [int] NULL,
	[TransactionModeID] [int] NOT NULL,
	[ShowTransactionIcon] [bit] NOT NULL,
	[ShowTransactionDashboardButton] [bit] NOT NULL,
	[SortOrder] [int] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_FCView] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCView] ADD  DEFAULT ((0)) FOR [HideEmpty]
GO
ALTER TABLE [dbo].[FCView] ADD  DEFAULT ((0)) FOR [ReadOnly]
GO
ALTER TABLE [dbo].[FCView] ADD  DEFAULT ((0)) FOR [ShowRowSum]
GO
ALTER TABLE [dbo].[FCView] ADD  DEFAULT ((0)) FOR [ShowColumnSum]
GO
ALTER TABLE [dbo].[FCView] ADD  CONSTRAINT [DF_FCView_EnableGroupingCellWrite]  DEFAULT ((0)) FOR [EnableGroupingCellWrite]
GO
ALTER TABLE [dbo].[FCView] ADD  CONSTRAINT [DF_FCView_TransactionModeID]  DEFAULT ((1)) FOR [TransactionModeID]
GO
ALTER TABLE [dbo].[FCView] ADD  CONSTRAINT [DF_FCView_ShowTransactionIcon]  DEFAULT ((1)) FOR [ShowTransactionIcon]
GO
ALTER TABLE [dbo].[FCView] ADD  CONSTRAINT [DF_FCView_ShowTransactionDashboardButton]  DEFAULT ((1)) FOR [ShowTransactionDashboardButton]
GO
ALTER TABLE [dbo].[FCView] ADD  CONSTRAINT [DF_FCView_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCView]  WITH CHECK ADD  CONSTRAINT [FK_FCView_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCView] CHECK CONSTRAINT [FK_FCView_Company]
GO
ALTER TABLE [dbo].[FCView]  WITH CHECK ADD  CONSTRAINT [FK_FCView_FCHighLevelDistributionOption] FOREIGN KEY([GroupingCellDistributionOptionId])
REFERENCES [dbo].[FCHighLevelDistributionOption] ([ID])
GO
ALTER TABLE [dbo].[FCView] CHECK CONSTRAINT [FK_FCView_FCHighLevelDistributionOption]
GO
ALTER TABLE [dbo].[FCView]  WITH CHECK ADD  CONSTRAINT [FK_FCView_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCView] CHECK CONSTRAINT [FK_FCView_FCType]
GO
ALTER TABLE [dbo].[FCView]  WITH CHECK ADD  CONSTRAINT [FK_FCView_FCViewTransactionModeType] FOREIGN KEY([TransactionModeID])
REFERENCES [dbo].[FCViewTransactionModeType] ([ID])
GO
ALTER TABLE [dbo].[FCView] CHECK CONSTRAINT [FK_FCView_FCViewTransactionModeType]
GO
