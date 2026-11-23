SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSourceDimensionHierarchy](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceDimensionID] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[FiscalMonthOffset] [int] NULL,
	[SortOrder] [int] NULL,
	[IsDefault] [bit] NOT NULL,
 CONSTRAINT [PK_DataSourceDimensionHierarchy] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataSourceDimensionHierarchy] ADD  CONSTRAINT [DF_DataSourceDimensionHierarchy_IsDefault]  DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[DataSourceDimensionHierarchy]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceDimensionHierarchy_DataSourceDimension] FOREIGN KEY([DataSourceDimensionID])
REFERENCES [dbo].[DataSourceDimension] ([ID])
GO
ALTER TABLE [dbo].[DataSourceDimensionHierarchy] CHECK CONSTRAINT [FK_DataSourceDimensionHierarchy_DataSourceDimension]
GO
