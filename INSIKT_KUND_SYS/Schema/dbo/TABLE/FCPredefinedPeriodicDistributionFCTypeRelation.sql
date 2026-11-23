SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCPredefinedPeriodicDistributionFCTypeRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PredefinedPeriodicDistributionID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
 CONSTRAINT [PK_PPDFCTypeRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_PPDFCTypeRelation] UNIQUE NONCLUSTERED 
(
	[PredefinedPeriodicDistributionID] ASC,
	[FCTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistributionFCTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_PPDFCTypeRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistributionFCTypeRelation] CHECK CONSTRAINT [FK_PPDFCTypeRelation_FCType]
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistributionFCTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_PPDFCTypeRelation_PredefinedPeriodicDistributionID] FOREIGN KEY([PredefinedPeriodicDistributionID])
REFERENCES [dbo].[FCPredefinedPeriodicDistribution] ([ID])
GO
ALTER TABLE [dbo].[FCPredefinedPeriodicDistributionFCTypeRelation] CHECK CONSTRAINT [FK_PPDFCTypeRelation_PredefinedPeriodicDistributionID]
GO
