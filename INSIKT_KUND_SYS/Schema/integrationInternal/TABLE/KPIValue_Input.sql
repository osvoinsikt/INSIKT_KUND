SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [integrationInternal].[KPIValue_Input](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KPIKey] [nvarchar](15) NOT NULL,
	[ScorecardPeriodID] [int] NOT NULL,
	[OrganisationMemberElementKey] [nvarchar](255) NULL,
	[Value] [decimal](28, 8) NULL,
	[ValueStatus] [int] NULL,
	[IsProcessed] [bit] NOT NULL,
	[ProcessedDate] [datetime] NULL,
	[ErrorOccured] [bit] NOT NULL,
	[ErrorMessage] [nvarchar](max) NULL,
 CONSTRAINT [PK_IntegrationInternal_KPIValue_Input] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [integrationInternal].[KPIValue_Input] ADD  CONSTRAINT [DF_IntegrationInternal_KPIValue_Input_IsProcessed]  DEFAULT ((0)) FOR [IsProcessed]
GO
ALTER TABLE [integrationInternal].[KPIValue_Input] ADD  CONSTRAINT [DF_IntegrationInternal_KPIValue_Input_ErrorOccured]  DEFAULT ((0)) FOR [ErrorOccured]
GO
