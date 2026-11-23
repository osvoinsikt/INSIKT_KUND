SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AIToolCallLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[RunningAsUserID] [int] NULL,
	[ToolName] [varchar](100) NOT NULL,
	[Arguments] [nvarchar](max) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AIToolCallLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[AIToolCallLog]  WITH CHECK ADD  CONSTRAINT [FK_AIToolCallLog_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[AIToolCallLog] CHECK CONSTRAINT [FK_AIToolCallLog_UserSecurityGroup]
GO
ALTER TABLE [dbo].[AIToolCallLog]  WITH CHECK ADD  CONSTRAINT [FK_AIToolCallLog_UserSecurityGroup_RunningAsUserID] FOREIGN KEY([RunningAsUserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[AIToolCallLog] CHECK CONSTRAINT [FK_AIToolCallLog_UserSecurityGroup_RunningAsUserID]
GO
