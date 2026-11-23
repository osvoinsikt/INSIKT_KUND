SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[fact_Projekt_Utilities_FactCDC](
	[CDC_ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectID] [int] NOT NULL,
	[FCVersionID] [int] NOT NULL,
	[PrevFCVersionID] [decimal](18, 0) NULL,
	[StartMonthID] [decimal](18, 0) NULL,
	[StartWritabilityMonthID] [decimal](18, 0) NULL,
	[EndMonthID] [decimal](18, 0) NULL,
	[LastUtfallMonthID] [decimal](18, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[CDC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
