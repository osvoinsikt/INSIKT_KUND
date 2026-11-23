SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSourceLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceMeasureGroupID] [int] NOT NULL,
	[EventTime] [datetime] NOT NULL,
	[LogStatusTypeID] [int] NOT NULL,
	[Message] [nvarchar](500) NULL,
	[DataUpdatedTime] [datetime] NOT NULL,
 CONSTRAINT [PK_DataSourceLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataSourceLog]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceLog_DataSourcesMeasureGroup] FOREIGN KEY([DataSourceMeasureGroupID])
REFERENCES [dbo].[DataSourcesMeasureGroup] ([ID])
GO
ALTER TABLE [dbo].[DataSourceLog] CHECK CONSTRAINT [FK_DataSourceLog_DataSourcesMeasureGroup]
GO
ALTER TABLE [dbo].[DataSourceLog]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceLog_LogStatusType] FOREIGN KEY([LogStatusTypeID])
REFERENCES [dbo].[LogStatusType] ([ID])
GO
ALTER TABLE [dbo].[DataSourceLog] CHECK CONSTRAINT [FK_DataSourceLog_LogStatusType]
GO
