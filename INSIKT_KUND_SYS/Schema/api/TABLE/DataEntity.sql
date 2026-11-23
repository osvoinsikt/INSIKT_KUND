SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [api].[DataEntity](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[FurtherInstruction] [nvarchar](max) NULL,
	[DirectionID] [int] NOT NULL,
	[DataFormatID] [int] NOT NULL,
	[URL] [nvarchar](255) NOT NULL,
	[DbName] [nvarchar](500) NULL,
	[SchemaName] [nvarchar](500) NULL,
	[TableName] [nvarchar](500) NULL,
 CONSTRAINT [PK_DataEntityID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [api].[DataEntity]  WITH CHECK ADD  CONSTRAINT [FK_DataEntity_DataFormat] FOREIGN KEY([DataFormatID])
REFERENCES [api].[DataFormat] ([ID])
GO
ALTER TABLE [api].[DataEntity] CHECK CONSTRAINT [FK_DataEntity_DataFormat]
GO
ALTER TABLE [api].[DataEntity]  WITH CHECK ADD  CONSTRAINT [FK_DataEntity_Direction] FOREIGN KEY([DirectionID])
REFERENCES [api].[Direction] ([ID])
GO
ALTER TABLE [api].[DataEntity] CHECK CONSTRAINT [FK_DataEntity_Direction]
GO
