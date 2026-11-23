SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[Vision](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Title] [nvarchar](300) NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[ModelTypeID] [int] NOT NULL,
 CONSTRAINT [PK_Scorecard_Vision] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [scorecard].[Vision]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Vision_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[Vision] CHECK CONSTRAINT [FK_Scorecard_Vision_CreatedBy]
GO
ALTER TABLE [scorecard].[Vision]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Vision_ModelTypeID] FOREIGN KEY([ModelTypeID])
REFERENCES [scorecard].[ModelType] ([ID])
GO
ALTER TABLE [scorecard].[Vision] CHECK CONSTRAINT [FK_Scorecard_Vision_ModelTypeID]
GO
ALTER TABLE [scorecard].[Vision]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Vision_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[Vision] CHECK CONSTRAINT [FK_Scorecard_Vision_ModifiedBy]
GO
