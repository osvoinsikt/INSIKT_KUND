SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCTypeDataSourceRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[DataSourceID] [int] NOT NULL,
 CONSTRAINT [PK_FCTypeDataSourceRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCTypeDataSourceRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCTypeDataSourceRelation_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCTypeDataSourceRelation] CHECK CONSTRAINT [FK_FCTypeDataSourceRelation_Company]
GO
ALTER TABLE [dbo].[FCTypeDataSourceRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCTypeDataSourceRelation_DataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DataSources] ([ID])
GO
ALTER TABLE [dbo].[FCTypeDataSourceRelation] CHECK CONSTRAINT [FK_FCTypeDataSourceRelation_DataSource]
GO
ALTER TABLE [dbo].[FCTypeDataSourceRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCTypeDataSourceRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCTypeDataSourceRelation] CHECK CONSTRAINT [FK_FCTypeDataSourceRelation_FCType]
GO
