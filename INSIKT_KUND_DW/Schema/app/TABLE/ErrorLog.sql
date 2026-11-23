SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[ErrorLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ETLID] [int] NULL,
	[EventID] [int] NULL,
	[SPID] [int] NOT NULL,
	[ErrorTime] [datetime] NOT NULL,
	[ErrorUser] [sysname] NOT NULL,
	[ErrorNumber] [int] NULL,
	[ErrorSeverity] [int] NULL,
	[ErrorState] [int] NULL,
	[ErrorProcedure] [nvarchar](128) NULL,
	[ErrorLine] [int] NULL,
	[ErrorMessage] [nvarchar](4000) NOT NULL,
 CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [app].[ErrorLog] ADD  CONSTRAINT [DF_ErrorLog_ErrorTime]  DEFAULT (getdate()) FOR [ErrorTime]
GO
ALTER TABLE [app].[ErrorLog] ADD  CONSTRAINT [DF_ErrorLog_User]  DEFAULT (CONVERT([sysname],user_name(),(0))) FOR [ErrorUser]
GO
ALTER TABLE [app].[ErrorLog]  WITH CHECK ADD  CONSTRAINT [FK_ErrorLog_EventLog] FOREIGN KEY([EventID])
REFERENCES [app].[EventLog] ([ID])
GO
ALTER TABLE [app].[ErrorLog] CHECK CONSTRAINT [FK_ErrorLog_EventLog]
GO
