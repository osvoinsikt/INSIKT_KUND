SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCDefaultPeriodicDistribution](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[ColumnUniqueName] [nvarchar](150) NOT NULL,
	[PredefinedPeriodicDistributionID] [int] NOT NULL,
	[FCVersionID] [int] NULL,
 CONSTRAINT [PK_FCDefaultPeriodicDistribution] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCDefaultPeriodicDistribution]  WITH CHECK ADD  CONSTRAINT [FK_FCDefaultPeriodicDistribution_PredefinedPeriodicDistribution] FOREIGN KEY([PredefinedPeriodicDistributionID])
REFERENCES [dbo].[FCPredefinedPeriodicDistribution] ([ID])
GO
ALTER TABLE [dbo].[FCDefaultPeriodicDistribution] CHECK CONSTRAINT [FK_FCDefaultPeriodicDistribution_PredefinedPeriodicDistribution]
GO
