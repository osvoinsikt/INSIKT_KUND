SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCViewGridMetadataRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[GridMetadataID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[FCViewID] [int] NULL,
	[CompanyID] [int] NOT NULL,
 CONSTRAINT [PK_FCViewGridMetadataRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCViewGridMetadataRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCViewGridMetadataRelation_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCViewGridMetadataRelation] CHECK CONSTRAINT [FK_FCViewGridMetadataRelation_Company]
GO
ALTER TABLE [dbo].[FCViewGridMetadataRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCViewGridMetadataRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCViewGridMetadataRelation] CHECK CONSTRAINT [FK_FCViewGridMetadataRelation_FCType]
GO
ALTER TABLE [dbo].[FCViewGridMetadataRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCViewGridMetadataRelation_FCView] FOREIGN KEY([FCViewID])
REFERENCES [dbo].[FCView] ([ID])
GO
ALTER TABLE [dbo].[FCViewGridMetadataRelation] CHECK CONSTRAINT [FK_FCViewGridMetadataRelation_FCView]
GO
ALTER TABLE [dbo].[FCViewGridMetadataRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCViewGridMetadataRelation_GridMetadata] FOREIGN KEY([GridMetadataID])
REFERENCES [dbo].[GridMetadata] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FCViewGridMetadataRelation] CHECK CONSTRAINT [FK_FCViewGridMetadataRelation_GridMetadata]
GO
