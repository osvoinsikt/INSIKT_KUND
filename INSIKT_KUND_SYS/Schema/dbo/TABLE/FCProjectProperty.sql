SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCProjectProperty](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Datatype] [varchar](50) NOT NULL,
	[ReadOnly] [bit] NOT NULL,
	[QueryToSetReadOnly] [nvarchar](max) NULL,
	[ControlID] [int] NOT NULL,
	[Visible] [bit] NOT NULL,
	[isProjectID] [bit] NOT NULL,
	[isProjectName] [bit] NOT NULL,
	[isProjectCode] [bit] NOT NULL,
	[SortOrder] [int] NULL,
	[QueryToFillPredefinedValues] [nvarchar](max) NULL,
	[isUser] [bit] NOT NULL,
	[isMandatory] [bit] NOT NULL,
	[isMultiselect] [bit] NOT NULL,
	[isTotalSumForValue] [bit] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[Indent] [int] NOT NULL,
	[QueryToComputeValue] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[DisableIsUserPreselection] [bit] NOT NULL,
	[isParentProject] [bit] NOT NULL,
	[DisablePredefinedValueCache] [bit] NOT NULL,
	[IsSearchable] [bit] NOT NULL,
	[ConfirmText] [nvarchar](max) NULL,
	[IsDeleted] [bit] NOT NULL,
	[DisplayName] [nvarchar](255) NULL,
	[Placeholder] [nvarchar](255) NULL,
	[RoleID] [int] NULL,
	[FormatString] [nvarchar](50) NULL,
 CONSTRAINT [PK_FCProjectProperty] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCProjectProperty] ADD  CONSTRAINT [DF_FCProjectProperty_ReadOnly]  DEFAULT ((0)) FOR [ReadOnly]
GO
ALTER TABLE [dbo].[FCProjectProperty] ADD  CONSTRAINT [DF_FCProjectProperty_isProjectID]  DEFAULT ((0)) FOR [isProjectID]
GO
ALTER TABLE [dbo].[FCProjectProperty] ADD  CONSTRAINT [DF_FCProjectProperty_isProjectName]  DEFAULT ((0)) FOR [isProjectName]
GO
ALTER TABLE [dbo].[FCProjectProperty] ADD  CONSTRAINT [DF_FCProjectProperty_isUser]  DEFAULT ((0)) FOR [isUser]
GO
ALTER TABLE [dbo].[FCProjectProperty] ADD  CONSTRAINT [DF_FCProjectProperty_Indent]  DEFAULT ((0)) FOR [Indent]
GO
ALTER TABLE [dbo].[FCProjectProperty] ADD  CONSTRAINT [DF_FCProjectProperty_DisableIsUserPreselection]  DEFAULT ((0)) FOR [DisableIsUserPreselection]
GO
ALTER TABLE [dbo].[FCProjectProperty] ADD  CONSTRAINT [DF_FCProjectProperty_isParentProject]  DEFAULT ((0)) FOR [isParentProject]
GO
ALTER TABLE [dbo].[FCProjectProperty] ADD  CONSTRAINT [DF_FCProjectProperty_DisablePredefinedValueCache]  DEFAULT ((0)) FOR [DisablePredefinedValueCache]
GO
ALTER TABLE [dbo].[FCProjectProperty] ADD  CONSTRAINT [DF_FCProjectProperty_IsSearchable]  DEFAULT ((1)) FOR [IsSearchable]
GO
ALTER TABLE [dbo].[FCProjectProperty] ADD  CONSTRAINT [DF_FCProjectProperty_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCProjectProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProperty_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProperty] CHECK CONSTRAINT [FK_FCProjectProperty_CompanyID]
GO
ALTER TABLE [dbo].[FCProjectProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProperty_Datatype] FOREIGN KEY([Datatype])
REFERENCES [dbo].[FCProjectPropertyDatatype] ([Name])
GO
ALTER TABLE [dbo].[FCProjectProperty] CHECK CONSTRAINT [FK_FCProjectProperty_Datatype]
GO
ALTER TABLE [dbo].[FCProjectProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProperty_FCProjectPropertyControl] FOREIGN KEY([ControlID])
REFERENCES [dbo].[FCProjectPropertyControl] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProperty] CHECK CONSTRAINT [FK_FCProjectProperty_FCProjectPropertyControl]
GO
ALTER TABLE [dbo].[FCProjectProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProperty_FCTypeID] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProperty] CHECK CONSTRAINT [FK_FCProjectProperty_FCTypeID]
GO
ALTER TABLE [dbo].[FCProjectProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProperty_Role] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Role] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProperty] CHECK CONSTRAINT [FK_FCProjectProperty_Role]
GO
