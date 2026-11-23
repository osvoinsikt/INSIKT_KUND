SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[HierarchyExtraColumn](
	[HierarchyExtraColumnID] [int] IDENTITY(1,1) NOT NULL,
	[HierarchyID] [int] NOT NULL,
	[ColumnName] [sysname] NOT NULL,
	[ValueExpression] [nvarchar](1000) NOT NULL,
	[DataType] [varchar](100) NOT NULL,
	[DefaultEmptyValueExpression] [nvarchar](1000) NULL,
 CONSTRAINT [PK_app_HierarchyExtraColumn] PRIMARY KEY CLUSTERED 
(
	[HierarchyExtraColumnID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_app_HierarchyExtraColumn_HierarchyName] UNIQUE NONCLUSTERED 
(
	[HierarchyID] ASC,
	[ColumnName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [app].[HierarchyExtraColumn]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyExtraColumn_Hierarchy] FOREIGN KEY([HierarchyID])
REFERENCES [app].[Hierarchy] ([HierarchyID])
GO
ALTER TABLE [app].[HierarchyExtraColumn] CHECK CONSTRAINT [FK_app_HierarchyExtraColumn_Hierarchy]
GO
