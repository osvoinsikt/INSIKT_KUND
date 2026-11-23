SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCTypeGroupRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[GroupID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[SortOrder] [int] NOT NULL,
	[IsPrimary] [bit] NOT NULL,
 CONSTRAINT [PK_FCTypeGroupRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCTypeGroupRelation] ADD  CONSTRAINT [DF_FCTypeGroupRelation_IsPrimary]  DEFAULT ((0)) FOR [IsPrimary]
GO
ALTER TABLE [dbo].[FCTypeGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCTypeGroupRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCTypeGroupRelation] CHECK CONSTRAINT [FK_FCTypeGroupRelation_FCType]
GO
ALTER TABLE [dbo].[FCTypeGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCTypeGroupRelation_FCTypeGroup] FOREIGN KEY([GroupID])
REFERENCES [dbo].[FCTypeGroup] ([ID])
GO
ALTER TABLE [dbo].[FCTypeGroupRelation] CHECK CONSTRAINT [FK_FCTypeGroupRelation_FCTypeGroup]
GO
