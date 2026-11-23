SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[ModelType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
	[IsRestricted] [bit] NOT NULL,
	[OrganisationID] [int] NOT NULL,
 CONSTRAINT [PK_Scorecard_ModelType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [scorecard].[ModelType] ADD  CONSTRAINT [DF_Scorecard_ModelType_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [scorecard].[ModelType] ADD  CONSTRAINT [DF_Scorecard_ModelType_IsRestricted]  DEFAULT ((0)) FOR [IsRestricted]
GO
ALTER TABLE [scorecard].[ModelType]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ModelType_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[ModelType] CHECK CONSTRAINT [FK_Scorecard_ModelType_CreatedBy]
GO
ALTER TABLE [scorecard].[ModelType]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ModelType_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[ModelType] CHECK CONSTRAINT [FK_Scorecard_ModelType_ModifiedBy]
GO
ALTER TABLE [scorecard].[ModelType]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Modeltype_OrganisationID] FOREIGN KEY([OrganisationID])
REFERENCES [scorecard].[Organisation] ([ID])
GO
ALTER TABLE [scorecard].[ModelType] CHECK CONSTRAINT [FK_Scorecard_Modeltype_OrganisationID]
GO
