SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[HierarchyNodeAttributeType](
	[HierarchyNodeAttributeTypeID] [int] IDENTITY(1,1) NOT NULL,
	[HierarchyID] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[DataTypeID] [char](4) NOT NULL,
 CONSTRAINT [PK_app_HierarchyNodeAttributeType] PRIMARY KEY CLUSTERED 
(
	[HierarchyNodeAttributeTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_app_HierarchyNodeAttributeType_HierarchyName] UNIQUE NONCLUSTERED 
(
	[HierarchyID] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [app].[HierarchyNodeAttributeType]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNodeAttributeType_DataType] FOREIGN KEY([DataTypeID])
REFERENCES [app].[DataType] ([DataTypeID])
GO
ALTER TABLE [app].[HierarchyNodeAttributeType] CHECK CONSTRAINT [FK_app_HierarchyNodeAttributeType_DataType]
GO
ALTER TABLE [app].[HierarchyNodeAttributeType]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyNodeAttributeType_Hierarchy] FOREIGN KEY([HierarchyID])
REFERENCES [app].[Hierarchy] ([HierarchyID])
GO
ALTER TABLE [app].[HierarchyNodeAttributeType] CHECK CONSTRAINT [FK_app_HierarchyNodeAttributeType_Hierarchy]
GO
