SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectPropertyGroupRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProjectPropertyGroupID] [int] NOT NULL,
	[ProjectPropertyID] [int] NOT NULL,
	[IsTitle] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectPropertyGroupRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectPropertyGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyGroupRelation_FCProjectProperty] FOREIGN KEY([ProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyGroupRelation] CHECK CONSTRAINT [FK_FCProjectPropertyGroupRelation_FCProjectProperty]
GO
ALTER TABLE [dbo].[FCProjectPropertyGroupRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyGroupRelation_FCProjectPropertyGroup] FOREIGN KEY([ProjectPropertyGroupID])
REFERENCES [dbo].[FCProjectPropertyGroup] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyGroupRelation] CHECK CONSTRAINT [FK_FCProjectPropertyGroupRelation_FCProjectPropertyGroup]
GO
