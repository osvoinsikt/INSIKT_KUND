SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCProjectComment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectID] [int] NOT NULL,
	[Title] [varchar](500) NULL,
	[Comment] [varchar](max) NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NULL,
	[FCProjectCalcProcessID] [int] NULL,
	[FCProjectCalcReviseReasonID] [int] NULL,
 CONSTRAINT [PK_FCProjectComment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCProjectComment] ADD  CONSTRAINT [DF_FCProjectComment_CreatedDate]  DEFAULT (getutcdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[FCProjectComment]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectComment_FCProject] FOREIGN KEY([FCProjectID])
REFERENCES [dbo].[FCProject] ([ID])
GO
ALTER TABLE [dbo].[FCProjectComment] CHECK CONSTRAINT [FK_FCProjectComment_FCProject]
GO
ALTER TABLE [dbo].[FCProjectComment]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectComment_FCProjectCalcProcess] FOREIGN KEY([FCProjectCalcProcessID])
REFERENCES [dbo].[FCProjectCalcProcess] ([ID])
GO
ALTER TABLE [dbo].[FCProjectComment] CHECK CONSTRAINT [FK_FCProjectComment_FCProjectCalcProcess]
GO
ALTER TABLE [dbo].[FCProjectComment]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectComment_FCProjectCalcReviseReason] FOREIGN KEY([FCProjectCalcReviseReasonID])
REFERENCES [dbo].[FCProjectCalcReviseReason] ([ID])
GO
ALTER TABLE [dbo].[FCProjectComment] CHECK CONSTRAINT [FK_FCProjectComment_FCProjectCalcReviseReason]
GO
ALTER TABLE [dbo].[FCProjectComment]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectComment_UserSecurityGroup] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProjectComment] CHECK CONSTRAINT [FK_FCProjectComment_UserSecurityGroup]
GO
