SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[CustomInvoiceFetcherConfig](
	[FetcherID] [varchar](50) NOT NULL,
	[DatabaseName] [varchar](512) NOT NULL,
	[QueueTable] [varchar](512) NOT NULL,
	[ResultTable] [varchar](512) NOT NULL,
	[AgentJobName] [varchar](512) NOT NULL,
	[AgentTimeoutInSecounds] [int] NOT NULL,
	[CheckForResultInterval] [varchar](12) NOT NULL,
 CONSTRAINT [PK_app_CustomInvoiceFetcherConfig] PRIMARY KEY CLUSTERED 
(
	[FetcherID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [app].[CustomInvoiceFetcherConfig] ADD  DEFAULT ((120)) FOR [AgentTimeoutInSecounds]
GO
ALTER TABLE [app].[CustomInvoiceFetcherConfig] ADD  DEFAULT ('00:00:00:500') FOR [CheckForResultInterval]
GO
ALTER TABLE [app].[CustomInvoiceFetcherConfig]  WITH CHECK ADD  CONSTRAINT [CHK_CheckForResultInterval_FormatMustMe: hh:mm[[:ss]].mss]]] CHECK  ((TRY_CAST([CheckForResultInterval] AS [time]) IS NOT NULL))
GO
ALTER TABLE [app].[CustomInvoiceFetcherConfig] CHECK CONSTRAINT [CHK_CheckForResultInterval_FormatMustMe: hh:mm[[:ss]].mss]]]
GO
