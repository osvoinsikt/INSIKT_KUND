SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [integrationInternal].[Dataset](
	[DatasetName] [varchar](128) NOT NULL,
	[Description] [nvarchar](4000) NULL,
	[DataTable] [varchar](1024) NULL,
	[LogicalPrimaryKeys] [varchar](4000) NULL,
	[InsiktProcessStatusColumns] [nvarchar](4000) NULL,
	[PostPutOperation] [nvarchar](4000) NULL,
 CONSTRAINT [PK_IntegrationInternal_Dataset] PRIMARY KEY CLUSTERED 
(
	[DatasetName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
