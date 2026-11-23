SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectTypeGroupRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCObjectTypeID] [int] NOT NULL,
	[FCObjectTypeGroupID] [int] NOT NULL,
	[SortOrder] [int] NULL,
 CONSTRAINT [PK_FCObjectTypeGroupRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCObjectTypeGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectTypeGroupRelation_FCObjectType] FOREIGN KEY([FCObjectTypeID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[FCObjectTypeGroupRelation] CHECK CONSTRAINT [FK_FCObjectTypeGroupRelation_FCObjectType]
GO
ALTER TABLE [dbo].[FCObjectTypeGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectTypeGroupRelation_FCObjectTypeGroup] FOREIGN KEY([FCObjectTypeGroupID])
REFERENCES [dbo].[FCObjectTypeGroup] ([ID])
GO
ALTER TABLE [dbo].[FCObjectTypeGroupRelation] CHECK CONSTRAINT [FK_FCObjectTypeGroupRelation_FCObjectTypeGroup]
GO
