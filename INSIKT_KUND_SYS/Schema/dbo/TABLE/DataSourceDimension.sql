SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSourceDimension](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceID] [int] NOT NULL,
	[DimensionName] [nvarchar](50) NOT NULL,
	[DisableCache] [bit] NOT NULL,
	[GeographyEnabled] [bit] NOT NULL,
	[MetadataQuery] [nvarchar](max) NULL,
	[NrOfPastYearsToShow] [int] NULL,
	[NrOfFutureYearsToShow] [int] NULL,
	[FCTypeID] [int] NULL,
	[IsProjectDimension] [bit] NOT NULL,
	[RootNodeCaption] [nvarchar](50) NULL,
 CONSTRAINT [PK_DataSourceDimension] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataSourceDimension] ADD  CONSTRAINT [DF_DataSourceDimension_DisableCache]  DEFAULT ((0)) FOR [DisableCache]
GO
ALTER TABLE [dbo].[DataSourceDimension] ADD  CONSTRAINT [DF_DataSourceDimension_GeographyEnabled]  DEFAULT ((0)) FOR [GeographyEnabled]
GO
ALTER TABLE [dbo].[DataSourceDimension] ADD  CONSTRAINT [DF_DataSourceDimension_IsProjectDimension]  DEFAULT ((0)) FOR [IsProjectDimension]
GO
ALTER TABLE [dbo].[DataSourceDimension]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceDimension_DataSources] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DataSources] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DataSourceDimension] CHECK CONSTRAINT [FK_DataSourceDimension_DataSources]
GO
ALTER TABLE [dbo].[DataSourceDimension]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceDimension_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[DataSourceDimension] CHECK CONSTRAINT [FK_DataSourceDimension_FCType]
GO
