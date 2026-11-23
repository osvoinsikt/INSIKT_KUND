SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectTypeView](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCObjectTypeID] [int] NOT NULL,
	[Name] [nvarchar](255) NULL,
	[ShowTotalRow] [bit] NOT NULL,
	[TotalRowName] [nvarchar](255) NULL,
	[IsDefault] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[SortOrder] [int] NULL,
	[DefaultSortColumnID] [int] NULL,
	[IsReverseSortOrder] [bit] NOT NULL,
	[Description] [nvarchar](255) NULL,
	[IsHidden] [bit] NOT NULL,
 CONSTRAINT [PK_FCObjectTypeView] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCObjectTypeView] ADD  CONSTRAINT [DF_FCObjectTypeView_ShowTotalRow]  DEFAULT ((0)) FOR [ShowTotalRow]
GO
ALTER TABLE [dbo].[FCObjectTypeView] ADD  CONSTRAINT [DF_FCObjectTypeView_IsDefault]  DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[FCObjectTypeView] ADD  CONSTRAINT [DF_FCObjectTypeView_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCObjectTypeView] ADD  CONSTRAINT [DF_FCObjectTypeView_IsReverseSortOrder]  DEFAULT ((0)) FOR [IsReverseSortOrder]
GO
ALTER TABLE [dbo].[FCObjectTypeView] ADD  CONSTRAINT [DF_FCObjectTypeView_IsHidden]  DEFAULT ((0)) FOR [IsHidden]
GO
ALTER TABLE [dbo].[FCObjectTypeView]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectTypeView_DefaultSortColumnID] FOREIGN KEY([DefaultSortColumnID])
REFERENCES [dbo].[FCObjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCObjectTypeView] CHECK CONSTRAINT [FK_FCObjectTypeView_DefaultSortColumnID]
GO
ALTER TABLE [dbo].[FCObjectTypeView]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectTypeView_FCObjectTypeID] FOREIGN KEY([FCObjectTypeID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[FCObjectTypeView] CHECK CONSTRAINT [FK_FCObjectTypeView_FCObjectTypeID]
GO
