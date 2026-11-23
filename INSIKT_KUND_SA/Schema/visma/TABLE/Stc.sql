SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [visma].[Stc](
	[StcNo] [int] NOT NULL,
	[Nm] [varchar](80) NOT NULL,
	[Ad1] [varchar](60) NOT NULL,
	[Ad2] [varchar](60) NOT NULL,
	[Ad3] [varchar](60) NOT NULL,
	[Ad4] [varchar](60) NOT NULL,
	[PNo] [varchar](40) NOT NULL,
	[PArea] [varchar](60) NOT NULL,
	[Rsp] [int] NOT NULL,
	[MailAd] [varchar](60) NOT NULL,
	[Phone] [varchar](20) NOT NULL,
	[Fax] [varchar](20) NOT NULL,
	[ChDt] [int] NOT NULL,
	[ChTm] [smallint] NOT NULL,
	[ChUsr] [varchar](24) NOT NULL,
	[LckSt] [tinyint] NOT NULL,
	[ChPrc] [int] NOT NULL,
	[ChSm] [int] NOT NULL,
	[PictFNm] [varchar](260) NOT NULL,
	[Ctry] [int] NOT NULL,
	[EANLocCd] [varchar](40) NOT NULL,
	[StcPro] [int] NOT NULL,
	[MainStc] [int] NOT NULL,
	[AcSet] [int] NOT NULL,
	[CreDt] [int] NOT NULL,
	[CreTm] [smallint] NOT NULL,
	[CreUsr] [varchar](24) NOT NULL,
	[SA_SourceSystemID] [int] NOT NULL,
 CONSTRAINT [PK_visma_Stc] PRIMARY KEY CLUSTERED 
(
	[SA_SourceSystemID] ASC,
	[StcNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
