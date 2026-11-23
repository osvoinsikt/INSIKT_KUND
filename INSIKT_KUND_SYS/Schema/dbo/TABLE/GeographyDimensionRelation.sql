SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GeographyDimensionRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceDimensionID] [int] NOT NULL,
	[HierarchyName] [nvarchar](250) NOT NULL,
	[MemberUniqueName] [nvarchar](250) NOT NULL,
	[GeographyID] [int] NOT NULL,
 CONSTRAINT [PK_GeographyDimensionRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[GeographyDimensionRelation]  WITH CHECK ADD  CONSTRAINT [FK_GeographyDimensionRelation_DataSourceDimension] FOREIGN KEY([DataSourceDimensionID])
REFERENCES [dbo].[DataSourceDimension] ([ID])
GO
ALTER TABLE [dbo].[GeographyDimensionRelation] CHECK CONSTRAINT [FK_GeographyDimensionRelation_DataSourceDimension]
GO
ALTER TABLE [dbo].[GeographyDimensionRelation]  WITH CHECK ADD  CONSTRAINT [FK_GeographyDimensionRelation_Geography] FOREIGN KEY([GeographyID])
REFERENCES [dbo].[Geography] ([ID])
GO
ALTER TABLE [dbo].[GeographyDimensionRelation] CHECK CONSTRAINT [FK_GeographyDimensionRelation_Geography]
GO
