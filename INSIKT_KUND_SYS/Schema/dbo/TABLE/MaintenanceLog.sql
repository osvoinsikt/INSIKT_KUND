SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MaintenanceLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[StopTime] [datetime] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[Message] [nvarchar](max) NULL,
	[TypeID] [int] NOT NULL,
	[MessageEnglish] [nvarchar](max) NULL,
	[AllowLogin] [bit] NOT NULL,
 CONSTRAINT [PK_MaintenanceLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[MaintenanceLog] ADD  CONSTRAINT [DF_MaintenanceLog_AllowLogin]  DEFAULT ((0)) FOR [AllowLogin]
GO
ALTER TABLE [dbo].[MaintenanceLog]  WITH CHECK ADD  CONSTRAINT [FK_MaintenanceLog_MaintenanceLogType] FOREIGN KEY([TypeID])
REFERENCES [dbo].[MaintenanceLogType] ([ID])
GO
ALTER TABLE [dbo].[MaintenanceLog] CHECK CONSTRAINT [FK_MaintenanceLog_MaintenanceLogType]
GO
ALTER TABLE [dbo].[MaintenanceLog]  WITH CHECK ADD  CONSTRAINT [FK_MaintenanceLog_UserSecurityGroup] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[MaintenanceLog] CHECK CONSTRAINT [FK_MaintenanceLog_UserSecurityGroup]
GO
