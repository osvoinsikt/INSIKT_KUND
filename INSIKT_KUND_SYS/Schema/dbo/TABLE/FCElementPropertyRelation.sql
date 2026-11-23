SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCElementPropertyRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[FCElementID] [int] NOT NULL,
	[FCPropertyID] [int] NOT NULL,
 CONSTRAINT [PK_FCElementPropertyRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCElementPropertyRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCElementPropertyRelation_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCElementPropertyRelation] CHECK CONSTRAINT [FK_FCElementPropertyRelation_Company]
GO
ALTER TABLE [dbo].[FCElementPropertyRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCElementPropertyRelation_FCElement] FOREIGN KEY([FCElementID])
REFERENCES [dbo].[FCElement] ([ID])
GO
ALTER TABLE [dbo].[FCElementPropertyRelation] CHECK CONSTRAINT [FK_FCElementPropertyRelation_FCElement]
GO
ALTER TABLE [dbo].[FCElementPropertyRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCElementPropertyRelation_FCProperty] FOREIGN KEY([FCPropertyID])
REFERENCES [dbo].[FCProperty] ([ID])
GO
ALTER TABLE [dbo].[FCElementPropertyRelation] CHECK CONSTRAINT [FK_FCElementPropertyRelation_FCProperty]
GO
ALTER TABLE [dbo].[FCElementPropertyRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCElementPropertyRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCElementPropertyRelation] CHECK CONSTRAINT [FK_FCElementPropertyRelation_FCType]
GO
