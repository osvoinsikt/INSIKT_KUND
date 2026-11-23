SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataUpdateJob](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DisplayName] [nvarchar](128) NULL,
	[Description] [nvarchar](512) NULL,
	[AgentJobName] [nvarchar](128) NOT NULL,
	[CategoryID] [int] NULL,
	[IsStartableByAdmin] [bit] NOT NULL,
	[IsLoopJob] [bit] NOT NULL,
	[IsSpecial] [bit] NOT NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ShowAsDefault] [bit] NOT NULL,
	[SystemDescription] [nvarchar](max) NULL,
 CONSTRAINT [PK_DataUpdateJob] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataUpdateJob] ADD  CONSTRAINT [DF_DataUpdateJob_ShowAsDefault]  DEFAULT ((1)) FOR [ShowAsDefault]
GO
ALTER TABLE [dbo].[DataUpdateJob]  WITH CHECK ADD  CONSTRAINT [FK_DataUpdateJob_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[DataUpdateJob] CHECK CONSTRAINT [FK_DataUpdateJob_CreatedBy]
GO
ALTER TABLE [dbo].[DataUpdateJob]  WITH CHECK ADD  CONSTRAINT [FK_DataUpdateJob_DataUpdateJobCategory] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[DataUpdateJobCategory] ([ID])
GO
ALTER TABLE [dbo].[DataUpdateJob] CHECK CONSTRAINT [FK_DataUpdateJob_DataUpdateJobCategory]
GO
ALTER TABLE [dbo].[DataUpdateJob]  WITH CHECK ADD  CONSTRAINT [FK_DataUpdateJob_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[DataUpdateJob] CHECK CONSTRAINT [FK_DataUpdateJob_ModifiedBy]
GO
