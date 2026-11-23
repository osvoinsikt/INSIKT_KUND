SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[Version](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Year] [int] NOT NULL,
	[Frequency] [int] NOT NULL,
	[Period] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
	[CopyFromVersionID] [int] NULL,
	[ModelTypeID] [int] NULL,
 CONSTRAINT [PK_Scorecard_Version] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [scorecard].[Version] ADD  CONSTRAINT [DF_Scorecard_Version_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [scorecard].[Version]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Version_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[Version] CHECK CONSTRAINT [FK_Scorecard_Version_CreatedBy]
GO
ALTER TABLE [scorecard].[Version]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Version_Frequency] FOREIGN KEY([Frequency])
REFERENCES [scorecard].[FrequencyType] ([ID])
GO
ALTER TABLE [scorecard].[Version] CHECK CONSTRAINT [FK_Scorecard_Version_Frequency]
GO
ALTER TABLE [scorecard].[Version]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Version_ModelTypeID] FOREIGN KEY([ModelTypeID])
REFERENCES [scorecard].[ModelType] ([ID])
GO
ALTER TABLE [scorecard].[Version] CHECK CONSTRAINT [FK_Scorecard_Version_ModelTypeID]
GO
ALTER TABLE [scorecard].[Version]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Version_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[Version] CHECK CONSTRAINT [FK_Scorecard_Version_ModifiedBy]
GO
ALTER TABLE [scorecard].[Version]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Version_Status] FOREIGN KEY([Status])
REFERENCES [scorecard].[VersionStatusType] ([ID])
GO
ALTER TABLE [scorecard].[Version] CHECK CONSTRAINT [FK_Scorecard_Version_Status]
GO
ALTER TABLE [scorecard].[Version]  WITH CHECK ADD  CONSTRAINT [FK_Version_CopyFromVersionID] FOREIGN KEY([CopyFromVersionID])
REFERENCES [scorecard].[Version] ([ID])
GO
ALTER TABLE [scorecard].[Version] CHECK CONSTRAINT [FK_Version_CopyFromVersionID]
GO
