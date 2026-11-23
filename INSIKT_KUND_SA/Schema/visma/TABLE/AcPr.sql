SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [visma].[AcPr](
	[Yr] [smallint] NOT NULL,
	[Pr] [smallint] NOT NULL,
	[FrDt] [int] NOT NULL,
	[ToDt] [int] NOT NULL,
	[ChDt] [int] NOT NULL,
	[ChTm] [smallint] NOT NULL,
	[ChUsr] [varchar](24) NOT NULL,
	[LckSt] [tinyint] NOT NULL,
	[ChPrc] [int] NOT NULL,
	[ChSm] [int] NOT NULL,
	[Descr] [varchar](80) NOT NULL,
	[ExPer] [tinyint] NOT NULL,
	[NxtPrBt] [int] NOT NULL,
	[CreDt] [int] NOT NULL,
	[CreTm] [smallint] NOT NULL,
	[CreUsr] [varchar](24) NOT NULL,
	[SA_SourceSystemID] [int] NOT NULL,
 CONSTRAINT [PK_visma_AcPr] PRIMARY KEY CLUSTERED 
(
	[SA_SourceSystemID] ASC,
	[Yr] ASC,
	[Pr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
