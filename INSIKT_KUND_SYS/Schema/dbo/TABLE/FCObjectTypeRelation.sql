SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectTypeRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCObjectTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_FCObjectTypeRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCObjectTypeRelation] ADD  CONSTRAINT [DF_FCObjectTypeRelation_SortOrder]  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[FCObjectTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectTypeRelation_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCObjectTypeRelation] CHECK CONSTRAINT [FK_FCObjectTypeRelation_Company]
GO
ALTER TABLE [dbo].[FCObjectTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectTypeRelation_FCObjectType] FOREIGN KEY([FCObjectTypeID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[FCObjectTypeRelation] CHECK CONSTRAINT [FK_FCObjectTypeRelation_FCObjectType]
GO
ALTER TABLE [dbo].[FCObjectTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectTypeRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCObjectTypeRelation] CHECK CONSTRAINT [FK_FCObjectTypeRelation_FCType]
GO
