SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCColumns](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UniqueName] [nvarchar](200) NOT NULL,
	[Caption] [nvarchar](200) NULL,
	[Order] [int] NULL,
	[Writable] [bit] NOT NULL,
	[Author] [varchar](50) NULL,
	[CompanyID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[MDX] [nvarchar](1000) NULL,
	[FCProcessDimUniqueName] [nvarchar](255) NULL,
	[DTDCustomQuery] [nvarchar](max) NULL,
	[PeriodicDistributable] [bit] NOT NULL,
	[AggregateValues] [bit] NOT NULL,
	[DisableDirectInput] [bit] NOT NULL,
	[Tooltip] [nvarchar](1000) NULL,
	[ReplaceByYear] [bit] NOT NULL,
	[IsHidden] [bit] NOT NULL,
	[CommentsAreMandatory] [bit] NOT NULL,
	[IsUnitPrice] [bit] NOT NULL,
	[IsDynamic] [bit] NOT NULL,
	[FilterMeasure] [varchar](255) NULL,
	[IgnoreLockedPeriods] [bit] NOT NULL,
	[PeriodsOffset] [int] NOT NULL,
	[HidePeriodicDistributionTotal] [bit] NOT NULL,
	[DefaultValueMeasure] [nvarchar](200) NULL,
	[CommentTemplate] [nvarchar](max) NULL,
	[WritabilityMeasure] [nvarchar](200) NULL,
	[ShowCommentsIcon] [bit] NOT NULL,
 CONSTRAINT [PK_FCColumns] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCColumns] ADD  CONSTRAINT [DF_FCColumns_Writable]  DEFAULT ((0)) FOR [Writable]
GO
ALTER TABLE [dbo].[FCColumns] ADD  CONSTRAINT [DF_FCColumns_PeriodicDistributable]  DEFAULT ((0)) FOR [PeriodicDistributable]
GO
ALTER TABLE [dbo].[FCColumns] ADD  CONSTRAINT [DF_FCColumns_Aggregate]  DEFAULT ((1)) FOR [AggregateValues]
GO
ALTER TABLE [dbo].[FCColumns] ADD  CONSTRAINT [DF_FCColumns_DisableDirectInput]  DEFAULT ((0)) FOR [DisableDirectInput]
GO
ALTER TABLE [dbo].[FCColumns] ADD  CONSTRAINT [DF_FCColumns_ReplaceByYear]  DEFAULT ((0)) FOR [ReplaceByYear]
GO
ALTER TABLE [dbo].[FCColumns] ADD  CONSTRAINT [DF_FCColumns_IsHidden]  DEFAULT ((0)) FOR [IsHidden]
GO
ALTER TABLE [dbo].[FCColumns] ADD  CONSTRAINT [DF_FCColumns_CommentsAreMandatory]  DEFAULT ((0)) FOR [CommentsAreMandatory]
GO
ALTER TABLE [dbo].[FCColumns] ADD  CONSTRAINT [DF_FCColumns_IsUnitPrice]  DEFAULT ((0)) FOR [IsUnitPrice]
GO
ALTER TABLE [dbo].[FCColumns] ADD  CONSTRAINT [DF_FCColumns_DynamicFCColumn]  DEFAULT ((0)) FOR [IsDynamic]
GO
ALTER TABLE [dbo].[FCColumns] ADD  CONSTRAINT [DF_FCColumns_PeriodsOffset]  DEFAULT ((0)) FOR [PeriodsOffset]
GO
ALTER TABLE [dbo].[FCColumns] ADD  CONSTRAINT [DF_FCColumns_HideperiodicDistributionTotal]  DEFAULT ((0)) FOR [HidePeriodicDistributionTotal]
GO
ALTER TABLE [dbo].[FCColumns] ADD  CONSTRAINT [DF_FCColumns_ShowCommentsIcon]  DEFAULT ((1)) FOR [ShowCommentsIcon]
GO
ALTER TABLE [dbo].[FCColumns]  WITH CHECK ADD  CONSTRAINT [FK_FCColumns_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCColumns] CHECK CONSTRAINT [FK_FCColumns_Company]
GO
ALTER TABLE [dbo].[FCColumns]  WITH CHECK ADD  CONSTRAINT [FK_FCColumns_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCColumns] CHECK CONSTRAINT [FK_FCColumns_FCType]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Kopplar kolumnen till en viss medlem i dimensionen i vänsterpanelen.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCColumns', @level2type=N'COLUMN',@level2name=N'FCProcessDimUniqueName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SQL-Fråga för DTD. Har företräde före den generella DTD-frågan specad i FCElementProperty' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCColumns', @level2type=N'COLUMN',@level2name=N'DTDCustomQuery'
GO
