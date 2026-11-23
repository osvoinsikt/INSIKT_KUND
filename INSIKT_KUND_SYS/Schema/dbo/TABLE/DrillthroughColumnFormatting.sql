SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DrillthroughColumnFormatting](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceID] [int] NULL,
	[DataSourcesMeasureGroupID] [int] NULL,
	[ColumnName] [nvarchar](200) NOT NULL,
	[FormatAsLink] [bit] NOT NULL,
	[Summation] [bit] NOT NULL,
	[VoucherLink] [bit] NOT NULL,
	[IsInvoiceLinkConfiguration] [bit] NOT NULL,
	[IsAmount] [bit] NOT NULL,
	[FormatString] [nvarchar](50) NULL,
	[FCObjectTypeID] [int] NULL,
 CONSTRAINT [PK_DrillthroughColumnFormatting] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[DrillthroughColumnFormatting] ADD  CONSTRAINT [DF_DrillthroughColumnFormatting_FormatAsLink]  DEFAULT ((0)) FOR [FormatAsLink]
GO
ALTER TABLE [dbo].[DrillthroughColumnFormatting] ADD  CONSTRAINT [DF_DrillthroughColumnFormatting_Summation]  DEFAULT ((0)) FOR [Summation]
GO
ALTER TABLE [dbo].[DrillthroughColumnFormatting] ADD  CONSTRAINT [DF_DrillthroughColumnFormatting_VoucherLink]  DEFAULT ((0)) FOR [VoucherLink]
GO
ALTER TABLE [dbo].[DrillthroughColumnFormatting] ADD  CONSTRAINT [DF_DrillthroughColumnFormatting_IsInvoiceLinkConfiguration]  DEFAULT ((0)) FOR [IsInvoiceLinkConfiguration]
GO
ALTER TABLE [dbo].[DrillthroughColumnFormatting] ADD  CONSTRAINT [DF_DrillthroughColumnFormatting_IsAmount]  DEFAULT ((0)) FOR [IsAmount]
GO
ALTER TABLE [dbo].[DrillthroughColumnFormatting]  WITH CHECK ADD  CONSTRAINT [FK_DrillthroughColumnFormatting_DataSources] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DataSources] ([ID])
GO
ALTER TABLE [dbo].[DrillthroughColumnFormatting] CHECK CONSTRAINT [FK_DrillthroughColumnFormatting_DataSources]
GO
ALTER TABLE [dbo].[DrillthroughColumnFormatting]  WITH CHECK ADD  CONSTRAINT [FK_DrillthroughColumnFormatting_DataSourcesMeasureGroup] FOREIGN KEY([DataSourcesMeasureGroupID])
REFERENCES [dbo].[DataSourcesMeasureGroup] ([ID])
GO
ALTER TABLE [dbo].[DrillthroughColumnFormatting] CHECK CONSTRAINT [FK_DrillthroughColumnFormatting_DataSourcesMeasureGroup]
GO
ALTER TABLE [dbo].[DrillthroughColumnFormatting]  WITH CHECK ADD  CONSTRAINT [FK_DrillthroughColumnFormatting_FCObjectTypeID] FOREIGN KEY([FCObjectTypeID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[DrillthroughColumnFormatting] CHECK CONSTRAINT [FK_DrillthroughColumnFormatting_FCObjectTypeID]
GO
