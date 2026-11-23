SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSourcePerspectiveMeasureRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourcePerspectiveID] [int] NOT NULL,
	[MeasureUniqueName] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_DataSourcePerspectiveMeasureRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataSourcePerspectiveMeasureRelation]  WITH CHECK ADD  CONSTRAINT [FK_DataSourcePerspectiveMeasureRelation_Perspective] FOREIGN KEY([DataSourcePerspectiveID])
REFERENCES [dbo].[DataSourcePerspective] ([ID])
GO
ALTER TABLE [dbo].[DataSourcePerspectiveMeasureRelation] CHECK CONSTRAINT [FK_DataSourcePerspectiveMeasureRelation_Perspective]
GO
