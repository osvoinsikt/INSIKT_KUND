SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectCalcAvailableVersionsSQL](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCTypeID] [int] NULL,
	[FCDashboardID] [int] NULL,
	[SQL] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_FCProjectCalcAvailableVersionsSQL] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectCalcAvailableVersionsSQL]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcAvailableVersionsSQL_FCDashboardID] FOREIGN KEY([FCDashboardID])
REFERENCES [dbo].[FCDashboard] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcAvailableVersionsSQL] CHECK CONSTRAINT [FK_FCProjectCalcAvailableVersionsSQL_FCDashboardID]
GO
ALTER TABLE [dbo].[FCProjectCalcAvailableVersionsSQL]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcAvailableVersionsSQL_FCTypeID] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcAvailableVersionsSQL] CHECK CONSTRAINT [FK_FCProjectCalcAvailableVersionsSQL_FCTypeID]
GO
