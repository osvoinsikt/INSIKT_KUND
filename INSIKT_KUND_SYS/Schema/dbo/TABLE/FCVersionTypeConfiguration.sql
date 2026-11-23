SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCVersionTypeConfiguration](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCVersionTypeID] [int] NOT NULL,
	[FCVersionFieldID] [int] NOT NULL,
	[IsVisible] [bit] NOT NULL,
	[ReadOnly] [bit] NOT NULL,
 CONSTRAINT [PK_FCVersionTypeConfiguration] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCVersionTypeConfiguration] ADD  CONSTRAINT [DF_FCVersionTypeConfiguration_IsVisible]  DEFAULT ((1)) FOR [IsVisible]
GO
ALTER TABLE [dbo].[FCVersionTypeConfiguration] ADD  CONSTRAINT [DF_FCVersionTypeConfiguration_ReadOnly]  DEFAULT ((0)) FOR [ReadOnly]
GO
ALTER TABLE [dbo].[FCVersionTypeConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_FCVersionTypeConfiguration_Field] FOREIGN KEY([FCVersionFieldID])
REFERENCES [dbo].[FCVersionField] ([ID])
GO
ALTER TABLE [dbo].[FCVersionTypeConfiguration] CHECK CONSTRAINT [FK_FCVersionTypeConfiguration_Field]
GO
ALTER TABLE [dbo].[FCVersionTypeConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_FCVersionTypeConfiguration_Type] FOREIGN KEY([FCVersionTypeID])
REFERENCES [dbo].[FCVersionType] ([ID])
GO
ALTER TABLE [dbo].[FCVersionTypeConfiguration] CHECK CONSTRAINT [FK_FCVersionTypeConfiguration_Type]
GO
