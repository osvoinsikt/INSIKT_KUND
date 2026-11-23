SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectPropertyPredefinedValue](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ValueNumeric] [float] NULL,
	[ValueString] [nvarchar](3000) NULL,
	[VisibleName] [nvarchar](255) NULL,
	[FCProjectPropertyID] [int] NOT NULL,
	[SortOrder] [int] NULL,
	[isDefault] [bit] NOT NULL,
	[AllowSelection] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectPropertyPredefinedValue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectPropertyPredefinedValue] ADD  CONSTRAINT [DF_FCProjectPropertyPredefinedValue_AllowSelection]  DEFAULT ((1)) FOR [AllowSelection]
GO
ALTER TABLE [dbo].[FCProjectPropertyPredefinedValue] ADD  CONSTRAINT [DF_FCProjectPropertyPredefinedValue_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCProjectPropertyPredefinedValue]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyPredefinedValue_FCProjectProperty] FOREIGN KEY([FCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyPredefinedValue] CHECK CONSTRAINT [FK_FCProjectPropertyPredefinedValue_FCProjectProperty]
GO
