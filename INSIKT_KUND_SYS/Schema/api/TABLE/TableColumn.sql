SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [api].[TableColumn](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataEntityID] [int] NOT NULL,
	[DataType] [varchar](50) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsPrimaryKey] [bit] NOT NULL,
	[IsVisibleInAPI] [bit] NOT NULL,
	[IsCursorKey] [bit] NOT NULL,
 CONSTRAINT [PK_TableColumnID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [api].[TableColumn] ADD  CONSTRAINT [DF_TableColumn_IsPrimaryKey]  DEFAULT ((0)) FOR [IsPrimaryKey]
GO
ALTER TABLE [api].[TableColumn] ADD  CONSTRAINT [DF_TableColumn_IsVisibleInAPI]  DEFAULT ((1)) FOR [IsVisibleInAPI]
GO
ALTER TABLE [api].[TableColumn] ADD  CONSTRAINT [DF_TableColumn_IsCursorKey]  DEFAULT ((0)) FOR [IsCursorKey]
GO
ALTER TABLE [api].[TableColumn]  WITH CHECK ADD  CONSTRAINT [FK_TableColumn_DataEntity] FOREIGN KEY([DataEntityID])
REFERENCES [api].[DataEntity] ([ID])
GO
ALTER TABLE [api].[TableColumn] CHECK CONSTRAINT [FK_TableColumn_DataEntity]
GO
