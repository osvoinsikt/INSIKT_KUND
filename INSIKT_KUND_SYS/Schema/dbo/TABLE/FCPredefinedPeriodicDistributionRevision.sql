SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCPredefinedPeriodicDistributionRevision](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCPredefinedPeriodicDistributionID] [int] NOT NULL,
	[RevisionNr] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](200) NOT NULL,
	[RevisionDate] [datetime] NULL,
	[RevisionBy] [int] NULL,
	[IsCommon] [bit] NOT NULL,
	[CategoryID] [int] NOT NULL,
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
	[CopyMeasureUniqueName] [nvarchar](50) NULL,
 CONSTRAINT [PK_FCPPDRevision] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_FCPPDRevision] UNIQUE NONCLUSTERED 
(
	[FCPredefinedPeriodicDistributionID] ASC,
	[RevisionNr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistributionRevision]  WITH CHECK ADD  CONSTRAINT [FK_FCPPDRevision_FCPPD] FOREIGN KEY([FCPredefinedPeriodicDistributionID])
REFERENCES [dbo].[FCPredefinedPeriodicDistribution] ([ID])
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistributionRevision] CHECK CONSTRAINT [FK_FCPPDRevision_FCPPD]
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistributionRevision]  WITH CHECK ADD  CONSTRAINT [FK_FCPPDRevision_FCPPDCategory] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[FCPredefinedPeriodicDistributionCategory] ([ID])
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistributionRevision] CHECK CONSTRAINT [FK_FCPPDRevision_FCPPDCategory]
GO
