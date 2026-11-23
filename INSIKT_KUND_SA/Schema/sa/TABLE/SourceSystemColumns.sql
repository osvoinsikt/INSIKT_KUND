SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [sa].[SourceSystemColumns](
	[SA_SourceSystemID] [int] NOT NULL,
	[SourceTable] [nvarchar](128) NOT NULL,
	[ColumnName] [nvarchar](128) NOT NULL,
	[ColumnOrder] [int] NOT NULL,
	[SqlDataTypeExpression] [varchar](512) NOT NULL,
	[Nullable] [bit] NOT NULL,
	[Collation] [varchar](512) NULL,
	[PrimaryKeyOrder] [int] NULL,
 CONSTRAINT [PK_SourceSystemColumns] PRIMARY KEY CLUSTERED 
(
	[SA_SourceSystemID] ASC,
	[SourceTable] ASC,
	[ColumnName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [sa].[SourceSystemColumns]  WITH CHECK ADD  CONSTRAINT [FK_SourceSystemColumns_base_SourceSystem] FOREIGN KEY([SA_SourceSystemID])
REFERENCES [sa].[base_SourceSystem] ([SA_SourceSystemID])
GO
ALTER TABLE [sa].[SourceSystemColumns] CHECK CONSTRAINT [FK_SourceSystemColumns_base_SourceSystem]
GO
