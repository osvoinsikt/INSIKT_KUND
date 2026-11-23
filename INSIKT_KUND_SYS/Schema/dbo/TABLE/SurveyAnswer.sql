SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SurveyAnswer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SurveyGroupID] [int] NOT NULL,
	[Score] [int] NULL,
	[Message] [nvarchar](max) NULL,
	[AnsweredDate] [datetime] NOT NULL,
	[UserRole] [nvarchar](255) NOT NULL,
	[UserFrequency] [nvarchar](255) NOT NULL,
	[UserFirstLogin] [nvarchar](255) NOT NULL,
	[Version] [nvarchar](100) NOT NULL,
	[InstallationYear] [nvarchar](100) NOT NULL,
	[InstallationSize] [nvarchar](100) NOT NULL,
	[PlanningTypesCount] [nvarchar](100) NOT NULL,
	[LangID] [int] NOT NULL,
 CONSTRAINT [PK_SurveyAnswer] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[SurveyAnswer]  WITH CHECK ADD  CONSTRAINT [FK_SurveyAnswer_SurveyGroup] FOREIGN KEY([SurveyGroupID])
REFERENCES [dbo].[SurveyGroup] ([ID])
GO
ALTER TABLE [dbo].[SurveyAnswer] CHECK CONSTRAINT [FK_SurveyAnswer_SurveyGroup]
GO
