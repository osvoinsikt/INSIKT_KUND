SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModuleFCTypeRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCTypeID] [int] NULL,
	[FCTypeGroupID] [int] NULL,
	[ModuleID] [int] NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_ModuleFCTypeRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[ModuleFCTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCType_ModuleFCTypeRelation] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[ModuleFCTypeRelation] CHECK CONSTRAINT [FK_FCType_ModuleFCTypeRelation]
GO
ALTER TABLE [dbo].[ModuleFCTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCTypeGroup_ModuleFCTypeRelation] FOREIGN KEY([FCTypeGroupID])
REFERENCES [dbo].[FCTypeGroup] ([ID])
GO
ALTER TABLE [dbo].[ModuleFCTypeRelation] CHECK CONSTRAINT [FK_FCTypeGroup_ModuleFCTypeRelation]
GO
ALTER TABLE [dbo].[ModuleFCTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_Module_ModuleFCTypeRelation] FOREIGN KEY([ModuleID])
REFERENCES [dbo].[Module] ([ID])
GO
ALTER TABLE [dbo].[ModuleFCTypeRelation] CHECK CONSTRAINT [FK_Module_ModuleFCTypeRelation]
GO
ALTER TABLE [dbo].[ModuleFCTypeRelation]  WITH CHECK ADD  CONSTRAINT [CK_ModuleFCTypeRelation] CHECK  (([FCTypeID] IS NOT NULL AND [FCTypeGroupID] IS NULL OR [FCTypeGroupID] IS NOT NULL AND [FCTypeID] IS NULL))
GO
ALTER TABLE [dbo].[ModuleFCTypeRelation] CHECK CONSTRAINT [CK_ModuleFCTypeRelation]
GO
