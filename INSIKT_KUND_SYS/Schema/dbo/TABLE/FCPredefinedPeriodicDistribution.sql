SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCPredefinedPeriodicDistribution](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[Description] [varchar](200) NULL,
	[PeriodPercent1] [decimal](18, 4) NULL,
	[PeriodPercent2] [decimal](18, 4) NULL,
	[PeriodPercent3] [decimal](18, 4) NULL,
	[PeriodPercent4] [decimal](18, 4) NULL,
	[PeriodPercent5] [decimal](18, 4) NULL,
	[PeriodPercent6] [decimal](18, 4) NULL,
	[PeriodPercent7] [decimal](18, 4) NULL,
	[PeriodPercent8] [decimal](18, 4) NULL,
	[PeriodPercent9] [decimal](18, 4) NULL,
	[PeriodPercent10] [decimal](18, 4) NULL,
	[PeriodPercent11] [decimal](18, 4) NULL,
	[PeriodPercent12] [decimal](18, 4) NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[isReadOnly] [bit] NOT NULL,
	[CompanyID] [int] NULL,
	[FCVersionID] [int] NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[IsCommon] [bit] NOT NULL,
	[CopyMeasureUniqueName] [nvarchar](50) NULL,
	[CategoryID] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[CurrentRevisionID] [int] NULL,
 CONSTRAINT [PK_PredefinedPeriodicDistribution] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistribution] ADD  CONSTRAINT [DF_FCPredefinedPeriodicDistribution_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistribution]  WITH CHECK ADD  CONSTRAINT [FK_FCPPD_FCPPDRevision] FOREIGN KEY([CurrentRevisionID])
REFERENCES [dbo].[FCPredefinedPeriodicDistributionRevision] ([ID])
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistribution] CHECK CONSTRAINT [FK_FCPPD_FCPPDRevision]
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistribution]  WITH CHECK ADD  CONSTRAINT [FK_FCPredefinedPeriodicDistribution_Category] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[FCPredefinedPeriodicDistributionCategory] ([ID])
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistribution] CHECK CONSTRAINT [FK_FCPredefinedPeriodicDistribution_Category]
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistribution]  WITH CHECK ADD  CONSTRAINT [FK_FCPredefinedPeriodicDistribution_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistribution] CHECK CONSTRAINT [FK_FCPredefinedPeriodicDistribution_Company]
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistribution]  WITH CHECK ADD  CONSTRAINT [FK_FCPredefinedPeriodicDistribution_FCVersion] FOREIGN KEY([FCVersionID])
REFERENCES [dbo].[FCVersion] ([ID])
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistribution] CHECK CONSTRAINT [FK_FCPredefinedPeriodicDistribution_FCVersion]
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistribution]  WITH CHECK ADD  CONSTRAINT [FK_FCPredefinedPeriodicDistribution_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistribution] CHECK CONSTRAINT [FK_FCPredefinedPeriodicDistribution_ModifiedBy]
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistribution]  WITH CHECK ADD  CONSTRAINT [FK_FCPredefinedPeriodicDistribution_UserSecurityGroup] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistribution] CHECK CONSTRAINT [FK_FCPredefinedPeriodicDistribution_UserSecurityGroup]
GO
