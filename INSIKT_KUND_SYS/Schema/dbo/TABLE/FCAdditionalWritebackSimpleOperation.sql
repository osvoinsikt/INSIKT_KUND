SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCAdditionalWritebackSimpleOperation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[DimensionName] [nvarchar](250) NOT NULL,
	[SourceElementKey] [nvarchar](max) NOT NULL,
	[TargetElementKey] [nvarchar](max) NOT NULL,
	[Percentage] [float] NOT NULL,
	[FCVersionID] [int] NULL,
	[SortOrder] [int] NULL,
 CONSTRAINT [PK_FCAdditionalWritebackSimpleOperation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCAdditionalWritebackSimpleOperation]  WITH CHECK ADD  CONSTRAINT [FK_FCAdditionalWritebackSimpleOperation_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCAdditionalWritebackSimpleOperation] CHECK CONSTRAINT [FK_FCAdditionalWritebackSimpleOperation_Company]
GO
ALTER TABLE [dbo].[FCAdditionalWritebackSimpleOperation]  WITH CHECK ADD  CONSTRAINT [FK_FCAdditionalWritebackSimpleOperation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCAdditionalWritebackSimpleOperation] CHECK CONSTRAINT [FK_FCAdditionalWritebackSimpleOperation_FCType]
GO
ALTER TABLE [dbo].[FCAdditionalWritebackSimpleOperation]  WITH CHECK ADD  CONSTRAINT [FK_FCAdditionalWritebackSimpleOperation_FCVersion] FOREIGN KEY([FCVersionID])
REFERENCES [dbo].[FCVersion] ([ID])
GO
ALTER TABLE [dbo].[FCAdditionalWritebackSimpleOperation] CHECK CONSTRAINT [FK_FCAdditionalWritebackSimpleOperation_FCVersion]
GO
