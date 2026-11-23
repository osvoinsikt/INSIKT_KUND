SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCHighLevelDistributionOption](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Caption] [nvarchar](50) NOT NULL,
	[UnitName] [nvarchar](max) NULL,
	[UniqueName] [nvarchar](100) NOT NULL,
	[FCHighLevelDistributionTypeID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[MethodID] [int] NOT NULL,
	[IgnoreOptionalHideEmpty] [bit] NOT NULL,
 CONSTRAINT [PK_FCHighLevelDistributionOption] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCHighLevelDistributionOption] ADD  CONSTRAINT [DF_FCHighLevelDistributionOption_IgnoreOptionalHideEmpty]  DEFAULT ((0)) FOR [IgnoreOptionalHideEmpty]
GO
ALTER TABLE [dbo].[FCHighLevelDistributionOption]  WITH CHECK ADD  CONSTRAINT [FK_FCHighLevelDistributionOption_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCHighLevelDistributionOption] CHECK CONSTRAINT [FK_FCHighLevelDistributionOption_Company]
GO
ALTER TABLE [dbo].[FCHighLevelDistributionOption]  WITH CHECK ADD  CONSTRAINT [FK_FCHighLevelDistributionOption_FCHighLevelDistributionType] FOREIGN KEY([FCHighLevelDistributionTypeID])
REFERENCES [dbo].[FCHighLevelDistributionType] ([ID])
GO
ALTER TABLE [dbo].[FCHighLevelDistributionOption] CHECK CONSTRAINT [FK_FCHighLevelDistributionOption_FCHighLevelDistributionType]
GO
ALTER TABLE [dbo].[FCHighLevelDistributionOption]  WITH CHECK ADD  CONSTRAINT [FK_FCHighLevelDistributionOption_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCHighLevelDistributionOption] CHECK CONSTRAINT [FK_FCHighLevelDistributionOption_FCType]
GO
ALTER TABLE [dbo].[FCHighLevelDistributionOption]  WITH CHECK ADD  CONSTRAINT [FK_FCHighLevelDistributionOption_MethodID] FOREIGN KEY([MethodID])
REFERENCES [dbo].[FCHighLevelDistributionMethod] ([ID])
GO
ALTER TABLE [dbo].[FCHighLevelDistributionOption] CHECK CONSTRAINT [FK_FCHighLevelDistributionOption_MethodID]
GO
