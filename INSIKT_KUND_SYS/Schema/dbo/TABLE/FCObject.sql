SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObject](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCObjectTypeID] [int] NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Code] [nvarchar](50) NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [smalldatetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [smalldatetime] NULL,
	[isDeleted] [bit] NOT NULL,
	[isExternal] [bit] NOT NULL,
	[ParentID] [int] NULL,
	[IsReadOnly] [bit] NOT NULL,
	[AllowParentSelection] [bit] NOT NULL,
 CONSTRAINT [PK_FCObject] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCObject] ADD  CONSTRAINT [DF_FCObject_IsDeleted]  DEFAULT ((0)) FOR [isDeleted]
GO
ALTER TABLE [dbo].[FCObject] ADD  CONSTRAINT [DF_FCObject_IsExternal]  DEFAULT ((0)) FOR [isExternal]
GO
ALTER TABLE [dbo].[FCObject] ADD  CONSTRAINT [DF_FCObject_IsReadOnly]  DEFAULT ((0)) FOR [IsReadOnly]
GO
ALTER TABLE [dbo].[FCObject] ADD  CONSTRAINT [DF_FCObject_AllowParentSelection]  DEFAULT ((1)) FOR [AllowParentSelection]
GO
ALTER TABLE [dbo].[FCObject]  WITH CHECK ADD  CONSTRAINT [FK_FCObject_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCObject] CHECK CONSTRAINT [FK_FCObject_CreatedBy]
GO
ALTER TABLE [dbo].[FCObject]  WITH CHECK ADD  CONSTRAINT [FK_FCObject_FCObjectType] FOREIGN KEY([FCObjectTypeID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[FCObject] CHECK CONSTRAINT [FK_FCObject_FCObjectType]
GO
ALTER TABLE [dbo].[FCObject]  WITH CHECK ADD  CONSTRAINT [FK_FCObject_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCObject] CHECK CONSTRAINT [FK_FCObject_ModifiedBy]
GO
ALTER TABLE [dbo].[FCObject]  WITH CHECK ADD  CONSTRAINT [FK_FCObject_ParentID] FOREIGN KEY([ParentID])
REFERENCES [dbo].[FCObject] ([ID])
GO
ALTER TABLE [dbo].[FCObject] CHECK CONSTRAINT [FK_FCObject_ParentID]
GO
