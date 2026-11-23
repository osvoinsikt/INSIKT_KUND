SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCProjectPropertyValueFCViewRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectPropertyID] [int] NOT NULL,
	[ValueNumeric] [float] NULL,
	[ValueString] [varchar](3000) NULL,
	[FCProjectPropertyPredefinedValueID] [int] NULL,
	[FCViewID] [int] NULL,
	[SortOrder] [int] NULL,
	[IsDefault] [bit] NULL,
 CONSTRAINT [PK_FCProjectPropertyValueFCViewRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCProjectPropertyValueFCViewRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyValueFCViewRelation_FCProjectProperty] FOREIGN KEY([FCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyValueFCViewRelation] CHECK CONSTRAINT [FK_FCProjectPropertyValueFCViewRelation_FCProjectProperty]
GO
ALTER TABLE [dbo].[FCProjectPropertyValueFCViewRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyValueFCViewRelation_FCProjectPropertyPredefinedValue] FOREIGN KEY([FCProjectPropertyPredefinedValueID])
REFERENCES [dbo].[FCProjectPropertyPredefinedValue] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyValueFCViewRelation] CHECK CONSTRAINT [FK_FCProjectPropertyValueFCViewRelation_FCProjectPropertyPredefinedValue]
GO
ALTER TABLE [dbo].[FCProjectPropertyValueFCViewRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyValueFCViewRelation_FCView] FOREIGN KEY([FCViewID])
REFERENCES [dbo].[FCView] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyValueFCViewRelation] CHECK CONSTRAINT [FK_FCProjectPropertyValueFCViewRelation_FCView]
GO
