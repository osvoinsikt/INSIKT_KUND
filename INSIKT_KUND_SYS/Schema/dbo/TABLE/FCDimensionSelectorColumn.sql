SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCDimensionSelectorColumn](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DimensionName] [nvarchar](150) NOT NULL,
	[Caption] [varchar](150) NULL,
	[SortOrder] [int] NOT NULL,
	[ReadOnly] [bit] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[PreSelectDefaultMemberOnNewRow] [bit] NOT NULL,
 CONSTRAINT [PK_FCDimensionSelectorColumn] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCDimensionSelectorColumn]  WITH CHECK ADD  CONSTRAINT [FK_FCDimensionSelectorColumn_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCDimensionSelectorColumn] CHECK CONSTRAINT [FK_FCDimensionSelectorColumn_Company]
GO
ALTER TABLE [dbo].[FCDimensionSelectorColumn]  WITH CHECK ADD  CONSTRAINT [FK_FCDimensionSelectorColumn_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCDimensionSelectorColumn] CHECK CONSTRAINT [FK_FCDimensionSelectorColumn_FCType]
GO
