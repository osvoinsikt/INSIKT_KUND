SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCDimension](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DimensionName] [nvarchar](50) NULL,
	[CompanyID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[ElementKey] [nvarchar](50) NOT NULL,
	[Caption] [nvarchar](255) NOT NULL,
	[UniqueName] [nvarchar](255) NOT NULL,
	[Level] [int] NULL,
	[LevelName] [varchar](50) NULL,
	[LevelUniqueName] [nvarchar](255) NULL,
	[OptionalCode] [varchar](50) NULL,
	[ParentKey] [nvarchar](50) NULL,
	[isLeaf] [bit] NOT NULL,
	[SortOrder] [int] NULL,
 CONSTRAINT [PK_FCDimension_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_FCDimension] ON [dbo].[FCDimension]
(
	[FCTypeID] ASC,
	[CompanyID] ASC,
	[ElementKey] ASC
)
INCLUDE([UniqueName],[Caption],[Level],[LevelUniqueName],[ParentKey],[isLeaf]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_TrimmaSecurity] ON [dbo].[FCDimension]
(
	[DimensionName] ASC,
	[CompanyID] ASC,
	[FCTypeID] ASC,
	[ParentKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FCDimension]  WITH CHECK ADD  CONSTRAINT [FK_FCDimension_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCDimension] CHECK CONSTRAINT [FK_FCDimension_Company]
GO
ALTER TABLE [dbo].[FCDimension]  WITH CHECK ADD  CONSTRAINT [FK_FCDimension_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCDimension] CHECK CONSTRAINT [FK_FCDimension_FCType]
GO
