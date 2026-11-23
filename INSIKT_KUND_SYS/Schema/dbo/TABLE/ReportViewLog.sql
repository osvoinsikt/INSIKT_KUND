SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportViewLog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[UserID] [int] NOT NULL,
	[RunningAsUserID] [int] NULL,
	[ViewType] [int] NOT NULL,
	[ReportID] [int] NULL,
	[DataSourceID] [int] NULL,
	[Selection] [nvarchar](max) NOT NULL,
	[UsedAsAIContext] [bit] NOT NULL,
 CONSTRAINT [PK_ReportViewLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[ReportViewLog] ADD  CONSTRAINT [DF_ReportViewLog_UsedAsAIContext]  DEFAULT ((0)) FOR [UsedAsAIContext]
GO
