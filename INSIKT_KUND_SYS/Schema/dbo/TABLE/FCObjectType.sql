SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCObjectType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[IsStandAlone] [bit] NULL,
	[IsHidden] [bit] NULL,
	[IsDeleted] [bit] NOT NULL,
	[SystemDescription] [nvarchar](max) NULL,
	[ScopeToFCVersion] [bit] NOT NULL,
	[ParentID] [int] NULL,
	[EnableCommentsAndDocuments] [bit] NOT NULL,
	[TabName] [nvarchar](255) NULL,
	[DWDatabase] [nvarchar](100) NULL,
	[DWSchema] [nvarchar](50) NULL,
	[DWTable] [nvarchar](100) NULL,
	[Compact] [bit] NOT NULL,
	[SmartColumnWidths] [bit] NOT NULL,
	[UseCreateDialog] [bit] NOT NULL,
	[CanAddObjectsSQL] [nvarchar](max) NULL,
 CONSTRAINT [PK_FCObjectType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCObjectType] ADD  CONSTRAINT [DF_FCObjectType_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCObjectType] ADD  CONSTRAINT [DF_FCObjectType_ScopeToFCVersion]  DEFAULT ((0)) FOR [ScopeToFCVersion]
GO
ALTER TABLE [dbo].[FCObjectType] ADD  CONSTRAINT [DF_FCObjectType_EnableCommentsAndDocuments]  DEFAULT ((1)) FOR [EnableCommentsAndDocuments]
GO
ALTER TABLE [dbo].[FCObjectType] ADD  CONSTRAINT [DF_FCObjectType_Compact]  DEFAULT ((0)) FOR [Compact]
GO
ALTER TABLE [dbo].[FCObjectType] ADD  CONSTRAINT [DF_FCObjectType_SmartColumnWidths]  DEFAULT ((0)) FOR [SmartColumnWidths]
GO
ALTER TABLE [dbo].[FCObjectType] ADD  CONSTRAINT [DF_FCObjectType_UseCreateDialog]  DEFAULT ((0)) FOR [UseCreateDialog]
GO
ALTER TABLE [dbo].[FCObjectType]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectType_ParentID] FOREIGN KEY([ParentID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[FCObjectType] CHECK CONSTRAINT [FK_FCObjectType_ParentID]
GO
