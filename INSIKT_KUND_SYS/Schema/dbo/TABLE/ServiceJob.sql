SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceJob](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServiceJobTypeID] [int] NOT NULL,
	[Body] [nvarchar](max) NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[StartedDate] [datetime] NULL,
	[FinishedDate] [datetime] NULL,
	[Success] [bit] NOT NULL,
	[ResultBody] [nvarchar](max) NULL,
	[NotifyUserTypeID] [int] NOT NULL,
 CONSTRAINT [PK_ServiceJob] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_ServiceJob_NewJobs] ON [dbo].[ServiceJob]
(
	[FinishedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ServiceJob] ADD  CONSTRAINT [DF_ServiceJob_Success]  DEFAULT ((0)) FOR [Success]
GO
ALTER TABLE [dbo].[ServiceJob]  WITH CHECK ADD  CONSTRAINT [FK_ServiceJob_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[ServiceJob] CHECK CONSTRAINT [FK_ServiceJob_CreatedBy]
GO
ALTER TABLE [dbo].[ServiceJob]  WITH CHECK ADD  CONSTRAINT [FK_ServiceJob_ServiceJobNotifyUserType] FOREIGN KEY([NotifyUserTypeID])
REFERENCES [dbo].[ServiceJobNotifyUserType] ([ID])
GO
ALTER TABLE [dbo].[ServiceJob] CHECK CONSTRAINT [FK_ServiceJob_ServiceJobNotifyUserType]
GO
ALTER TABLE [dbo].[ServiceJob]  WITH CHECK ADD  CONSTRAINT [FK_ServiceJob_ServiceJobType] FOREIGN KEY([ServiceJobTypeID])
REFERENCES [dbo].[ServiceJobType] ([ID])
GO
ALTER TABLE [dbo].[ServiceJob] CHECK CONSTRAINT [FK_ServiceJob_ServiceJobType]
GO
