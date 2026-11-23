SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCElementPeriodicDistribution](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[PredefinedID] [int] NULL,
	[PeriodPercent1] [decimal](18, 8) NULL,
	[PeriodPercent2] [decimal](18, 8) NULL,
	[PeriodPercent3] [decimal](18, 8) NULL,
	[PeriodPercent4] [decimal](18, 8) NULL,
	[PeriodPercent5] [decimal](18, 8) NULL,
	[PeriodPercent6] [decimal](18, 8) NULL,
	[PeriodPercent7] [decimal](18, 8) NULL,
	[PeriodPercent8] [decimal](18, 8) NULL,
	[PeriodPercent9] [decimal](18, 8) NULL,
	[PeriodPercent10] [decimal](18, 8) NULL,
	[PeriodPercent11] [decimal](18, 8) NULL,
	[PeriodPercent12] [decimal](18, 8) NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[FCTypeID] [int] NOT NULL,
	[IsLocked] [bit] NULL,
	[PredefinedRevisionID] [int] NULL,
 CONSTRAINT [PK_ElementPeriodicDistribution] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_FCTypeID_CompanyID_ID] ON [dbo].[FCElementPeriodicDistribution]
(
	[FCTypeID] ASC,
	[CompanyID] ASC
)
INCLUDE([ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FCElementPeriodicDistribution]  WITH CHECK ADD  CONSTRAINT [FK_ElementPeriodicDistribution_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCElementPeriodicDistribution] CHECK CONSTRAINT [FK_ElementPeriodicDistribution_Company]
GO
ALTER TABLE [dbo].[FCElementPeriodicDistribution]  WITH CHECK ADD  CONSTRAINT [FK_ElementPeriodicDistribution_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCElementPeriodicDistribution] CHECK CONSTRAINT [FK_ElementPeriodicDistribution_FCType]
GO
ALTER TABLE [dbo].[FCElementPeriodicDistribution]  WITH CHECK ADD  CONSTRAINT [FK_ElementPeriodicDistribution_PredefinedPeriodicDistribution] FOREIGN KEY([PredefinedID])
REFERENCES [dbo].[FCPredefinedPeriodicDistribution] ([ID])
GO
ALTER TABLE [dbo].[FCElementPeriodicDistribution] CHECK CONSTRAINT [FK_ElementPeriodicDistribution_PredefinedPeriodicDistribution]
GO
ALTER TABLE [dbo].[FCElementPeriodicDistribution]  WITH CHECK ADD  CONSTRAINT [FK_FCElementPeriodicDistribution_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCElementPeriodicDistribution] CHECK CONSTRAINT [FK_FCElementPeriodicDistribution_ModifiedBy]
GO
ALTER TABLE [dbo].[FCElementPeriodicDistribution]  WITH CHECK ADD  CONSTRAINT [FK_FCEPD_FCPPDRevision] FOREIGN KEY([PredefinedRevisionID])
REFERENCES [dbo].[FCPredefinedPeriodicDistributionRevision] ([ID])
GO
ALTER TABLE [dbo].[FCElementPeriodicDistribution] CHECK CONSTRAINT [FK_FCEPD_FCPPDRevision]
GO
