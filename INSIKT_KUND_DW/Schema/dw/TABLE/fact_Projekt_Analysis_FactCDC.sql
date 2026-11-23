SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[fact_Projekt_Analysis_FactCDC](
	[CDC_ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectID] [int] NOT NULL,
	[DateID] [int] NOT NULL,
	[KontoID] [int] NOT NULL,
	[AktuellKalkyl] [numeric](28, 8) NULL,
	[PrevKalkyl] [numeric](28, 8) NULL,
	[Förkalkyl] [numeric](28, 8) NULL,
	[Budget] [numeric](28, 8) NULL,
	[Prognos] [numeric](28, 8) NULL,
	[PrevPrognos] [numeric](28, 8) NULL,
PRIMARY KEY CLUSTERED 
(
	[CDC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
