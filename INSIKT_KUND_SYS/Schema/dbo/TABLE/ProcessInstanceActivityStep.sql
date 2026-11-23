SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProcessInstanceActivityStep](
	[ProcessInstanceActivityID] [int] NOT NULL,
	[ProcessTemplateActivityStepRevisionID] [int] NULL,
	[IsHidden] [bit] NOT NULL,
	[FinishedDate] [datetime] NULL,
	[FinishedBy] [int] NULL,
	[Order] [int] NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Description] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
