SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[IncUpdate_Job](
	[JobID] [int] NOT NULL,
	[AgentJobName] [nvarchar](1024) NOT NULL,
	[Description] [nvarchar](4000) NULL,
	[WaitTime] [varchar](11) NULL,
	[Status] [varchar](20) NOT NULL,
	[LastStatusChangeBy] [varchar](500) NULL,
 CONSTRAINT [PK_IncUpdate_Job] PRIMARY KEY CLUSTERED 
(
	[JobID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [app].[IncUpdate_Job]  WITH CHECK ADD  CONSTRAINT [CHK_WaitTime_FormatMustMe: hh:mm[[:ss]].mss]]] CHECK  ((TRY_CAST([WaitTime] AS [time]) IS NOT NULL))
GO
ALTER TABLE [app].[IncUpdate_Job] CHECK CONSTRAINT [CHK_WaitTime_FormatMustMe: hh:mm[[:ss]].mss]]]
GO
ALTER TABLE [app].[IncUpdate_Job]  WITH CHECK ADD  CONSTRAINT [IncUpdate_Job_Status_Check] CHECK  (([Status]='Stopping' OR [Status]='Paused' OR [Status]='Pausing' OR [Status]='Running' OR [Status]='Stopped' OR [Status]='Error'))
GO
ALTER TABLE [app].[IncUpdate_Job] CHECK CONSTRAINT [IncUpdate_Job_Status_Check]
GO
