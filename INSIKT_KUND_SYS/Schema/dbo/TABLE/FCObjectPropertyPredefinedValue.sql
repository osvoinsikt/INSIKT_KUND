SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectPropertyPredefinedValue](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VisibleName] [nvarchar](255) NOT NULL,
	[ValueString] [nvarchar](255) NULL,
	[ValueNumeric] [float] NULL,
	[FCObjectPropertyID] [int] NOT NULL,
	[isDefault] [bit] NULL,
	[SortOrder] [int] NULL,
	[IsDeleted] [bit] NOT NULL,
	[AllowSelection] [bit] NOT NULL,
	[StyleID] [int] NULL,
 CONSTRAINT [PK_FCObjectPropertyPredefinedValue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCObjectPropertyPredefinedValue] ADD  CONSTRAINT [DF_FCObjectPropertyPredefinedValue_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCObjectPropertyPredefinedValue]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectPropertyPredefinedValue_FCObjectProperty] FOREIGN KEY([FCObjectPropertyID])
REFERENCES [dbo].[FCObjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCObjectPropertyPredefinedValue] CHECK CONSTRAINT [FK_FCObjectPropertyPredefinedValue_FCObjectProperty]
GO
ALTER TABLE [dbo].[FCObjectPropertyPredefinedValue]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectPropertyPredefinedValue_Style] FOREIGN KEY([StyleID])
REFERENCES [dbo].[FCObjectPropertyStyle] ([ID])
GO
ALTER TABLE [dbo].[FCObjectPropertyPredefinedValue] CHECK CONSTRAINT [FK_FCObjectPropertyPredefinedValue_Style]
GO
