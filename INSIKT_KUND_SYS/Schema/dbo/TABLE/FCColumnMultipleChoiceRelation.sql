SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCColumnMultipleChoiceRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessKey] [nvarchar](50) NOT NULL,
	[FCVersionID] [int] NOT NULL,
	[ColumnUniqueName] [nvarchar](200) NOT NULL,
	[MultipleChoiceID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
 CONSTRAINT [PK_FCColumnMultipleChoiceRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCColumnMultipleChoiceRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCColumnMultipleChoiceRelation_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCColumnMultipleChoiceRelation] CHECK CONSTRAINT [FK_FCColumnMultipleChoiceRelation_Company]
GO
ALTER TABLE [dbo].[FCColumnMultipleChoiceRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCColumnMultipleChoiceRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCColumnMultipleChoiceRelation] CHECK CONSTRAINT [FK_FCColumnMultipleChoiceRelation_FCType]
GO
ALTER TABLE [dbo].[FCColumnMultipleChoiceRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCColumnMultipleChoiceRelation_MultipleChoice] FOREIGN KEY([MultipleChoiceID])
REFERENCES [dbo].[MultipleChoice] ([ID])
GO
ALTER TABLE [dbo].[FCColumnMultipleChoiceRelation] CHECK CONSTRAINT [FK_FCColumnMultipleChoiceRelation_MultipleChoice]
GO
