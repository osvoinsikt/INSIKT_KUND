SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[HierarchyOptionType](
	[HierarchyOptionTypeID] [char](4) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[DataTypeID] [char](4) NOT NULL,
 CONSTRAINT [PK_app_HierarchyOptionType] PRIMARY KEY CLUSTERED 
(
	[HierarchyOptionTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [app].[HierarchyOptionType]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyOptionType_app_DataType] FOREIGN KEY([DataTypeID])
REFERENCES [app].[DataType] ([DataTypeID])
GO
ALTER TABLE [app].[HierarchyOptionType] CHECK CONSTRAINT [FK_app_HierarchyOptionType_app_DataType]
GO
