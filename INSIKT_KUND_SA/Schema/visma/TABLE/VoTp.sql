SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [visma].[VoTp](
	[VoTpNo] [int] NOT NULL,
	[StdTxt] [varchar](200) NOT NULL,
	[InpTxt] [tinyint] NOT NULL,
	[InpCur] [tinyint] NOT NULL,
	[AffTrn] [tinyint] NOT NULL,
	[IgnTxCd] [tinyint] NOT NULL,
	[DbAc] [int] NOT NULL,
	[CrAc] [int] NOT NULL,
	[SugAm] [tinyint] NOT NULL,
	[R1] [int] NOT NULL,
	[R2] [int] NOT NULL,
	[R3] [int] NOT NULL,
	[R4] [int] NOT NULL,
	[R5] [int] NOT NULL,
	[R6] [int] NOT NULL,
	[Pri] [int] NOT NULL,
	[ChDt] [int] NOT NULL,
	[ChTm] [smallint] NOT NULL,
	[ChUsr] [varchar](24) NOT NULL,
	[LckSt] [tinyint] NOT NULL,
	[ChPrc] [int] NOT NULL,
	[ChSm] [int] NOT NULL,
	[PropPrc] [tinyint] NOT NULL,
	[UpdOrd] [tinyint] NOT NULL,
	[Per] [tinyint] NOT NULL,
	[SrNo] [int] NOT NULL,
	[CompExRt] [tinyint] NOT NULL,
	[ExAut] [tinyint] NOT NULL,
	[RepInf] [tinyint] NOT NULL,
	[TrnCl] [tinyint] NOT NULL,
	[VoTpPrc] [int] NOT NULL,
	[ClPrc] [tinyint] NOT NULL,
	[PgElNo] [int] NOT NULL,
	[R7] [varchar](40) NOT NULL,
	[R8] [varchar](10) NOT NULL,
	[R9] [varchar](10) NOT NULL,
	[R10] [varchar](10) NOT NULL,
	[R11] [varchar](10) NOT NULL,
	[R12] [varchar](10) NOT NULL,
	[PmVCshP] [decimal](28, 6) NOT NULL,
	[PmVOtP] [decimal](28, 6) NOT NULL,
	[Txt2Def] [varchar](128) NOT NULL,
	[ProdNo] [varchar](40) NOT NULL,
	[CreDt] [int] NOT NULL,
	[CreTm] [smallint] NOT NULL,
	[CreUsr] [varchar](24) NOT NULL,
	[SA_SourceSystemID] [int] NOT NULL,
 CONSTRAINT [PK_visma_VoTp] PRIMARY KEY CLUSTERED 
(
	[SA_SourceSystemID] ASC,
	[VoTpNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
