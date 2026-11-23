SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCObjectProperty](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCObjectTypeID] [int] NOT NULL,
	[FCObjectPropertyControlID] [int] NOT NULL,
	[FCObjectPropertyDatatypeID] [int] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[isReadOnly] [bit] NOT NULL,
	[isExternal] [bit] NOT NULL,
	[isVisible] [bit] NULL,
	[SortOrder] [int] NULL,
	[isTitle] [bit] NULL,
	[DefaultValue] [varchar](3000) NULL,
	[isMandatory] [bit] NULL,
	[QueryToFillPredefinedValues] [nvarchar](max) NULL,
	[isObjectID] [bit] NOT NULL,
	[isObjectCode] [bit] NOT NULL,
	[isObjectName] [bit] NOT NULL,
	[isDefaultSortingColumn] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[IsObjectParentID] [bit] NOT NULL,
	[InlineEdit] [bit] NOT NULL,
	[Width] [int] NULL,
	[FormatString] [nvarchar](50) NULL,
	[Description] [nvarchar](max) NULL,
	[Placeholder] [nvarchar](255) NULL,
	[DWColumnName] [nvarchar](200) NULL,
	[VisibleName] [nvarchar](max) NULL,
	[GroupCalculationTypeID] [int] NULL,
	[IsReverseSortOrder] [bit] NOT NULL,
	[ReadOnlyFilterID] [int] NULL,
	[StylePropertyID] [int] NULL,
	[VisibleFilterID] [int] NULL,
 CONSTRAINT [PK_FCObjectProperty] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCObjectProperty] ADD  CONSTRAINT [DF_FCObjectProperty_isReadOnly]  DEFAULT ((0)) FOR [isReadOnly]
GO
ALTER TABLE [dbo].[FCObjectProperty] ADD  CONSTRAINT [DF_FCObjectProperty_isVisible]  DEFAULT ((1)) FOR [isVisible]
GO
ALTER TABLE [dbo].[FCObjectProperty] ADD  CONSTRAINT [DF_FCObjectProperty_isTitle]  DEFAULT ((0)) FOR [isTitle]
GO
ALTER TABLE [dbo].[FCObjectProperty] ADD  CONSTRAINT [DF_FCObjectProperty_isProjectID]  DEFAULT ((0)) FOR [isObjectID]
GO
ALTER TABLE [dbo].[FCObjectProperty] ADD  CONSTRAINT [DF_FCObjectProperty_isObjectCode]  DEFAULT ((0)) FOR [isObjectCode]
GO
ALTER TABLE [dbo].[FCObjectProperty] ADD  CONSTRAINT [DF_FCObjectProperty_isObjectName]  DEFAULT ((0)) FOR [isObjectName]
GO
ALTER TABLE [dbo].[FCObjectProperty] ADD  CONSTRAINT [DF_FCObjectProperty_isDefaultSortingColumn]  DEFAULT ((0)) FOR [isDefaultSortingColumn]
GO
ALTER TABLE [dbo].[FCObjectProperty] ADD  CONSTRAINT [DF_FCObjectProperty_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCObjectProperty] ADD  CONSTRAINT [DF_FCObjectProperty_IsObjectParentID]  DEFAULT ((0)) FOR [IsObjectParentID]
GO
ALTER TABLE [dbo].[FCObjectProperty] ADD  CONSTRAINT [DF_FCObjectProperty_InlineEdit]  DEFAULT ((0)) FOR [InlineEdit]
GO
ALTER TABLE [dbo].[FCObjectProperty] ADD  CONSTRAINT [DF_FCObjectProperty_IsReverseSortOrder]  DEFAULT ((0)) FOR [IsReverseSortOrder]
GO
ALTER TABLE [dbo].[FCObjectProperty]  WITH CHECK ADD  CONSTRAINT [FK_dbo_FCObjectProperty_GroupCalculationTypeID] FOREIGN KEY([GroupCalculationTypeID])
REFERENCES [dbo].[FCObjectPropertyCalculationType] ([ID])
GO
ALTER TABLE [dbo].[FCObjectProperty] CHECK CONSTRAINT [FK_dbo_FCObjectProperty_GroupCalculationTypeID]
GO
ALTER TABLE [dbo].[FCObjectProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectProperty_FCObjectPropertyControl] FOREIGN KEY([FCObjectPropertyControlID])
REFERENCES [dbo].[FCObjectPropertyControl] ([ID])
GO
ALTER TABLE [dbo].[FCObjectProperty] CHECK CONSTRAINT [FK_FCObjectProperty_FCObjectPropertyControl]
GO
ALTER TABLE [dbo].[FCObjectProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectProperty_FCObjectPropertyDatatype] FOREIGN KEY([FCObjectPropertyDatatypeID])
REFERENCES [dbo].[FCObjectPropertyDatatype] ([ID])
GO
ALTER TABLE [dbo].[FCObjectProperty] CHECK CONSTRAINT [FK_FCObjectProperty_FCObjectPropertyDatatype]
GO
ALTER TABLE [dbo].[FCObjectProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectProperty_FCObjectType] FOREIGN KEY([FCObjectTypeID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[FCObjectProperty] CHECK CONSTRAINT [FK_FCObjectProperty_FCObjectType]
GO
ALTER TABLE [dbo].[FCObjectProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectProperty_ReadOnlyFilter] FOREIGN KEY([ReadOnlyFilterID])
REFERENCES [dbo].[FCObjectPropertyFilter] ([ID])
GO
ALTER TABLE [dbo].[FCObjectProperty] CHECK CONSTRAINT [FK_FCObjectProperty_ReadOnlyFilter]
GO
ALTER TABLE [dbo].[FCObjectProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectProperty_StyleProperty] FOREIGN KEY([StylePropertyID])
REFERENCES [dbo].[FCObjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCObjectProperty] CHECK CONSTRAINT [FK_FCObjectProperty_StyleProperty]
GO
ALTER TABLE [dbo].[FCObjectProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectProperty_VisibleFilter] FOREIGN KEY([VisibleFilterID])
REFERENCES [dbo].[FCObjectPropertyFilter] ([ID])
GO
ALTER TABLE [dbo].[FCObjectProperty] CHECK CONSTRAINT [FK_FCObjectProperty_VisibleFilter]
GO
