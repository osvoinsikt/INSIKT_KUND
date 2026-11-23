SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[NullDimensionPartDefaults](
	[DimensionPartTypeID] [int] NOT NULL,
	[ColumnName] [sysname] NOT NULL,
	[SQLValueExpression] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_NullDimensionPartDefault] PRIMARY KEY CLUSTERED 
(
	[DimensionPartTypeID] ASC,
	[ColumnName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [app].[NullDimensionPartDefaults]  WITH CHECK ADD  CONSTRAINT [FK_NullDimensionPartDefaults_DimensionPartType] FOREIGN KEY([DimensionPartTypeID])
REFERENCES [app].[DimensionPartType] ([DimensionPartTypeID])
GO
ALTER TABLE [app].[NullDimensionPartDefaults] CHECK CONSTRAINT [FK_NullDimensionPartDefaults_DimensionPartType]
GO
