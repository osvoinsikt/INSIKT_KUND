SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCProjectCardObject](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectCardID] [int] NOT NULL,
	[FCProjectPropertyID] [int] NULL,
	[FCProjectPropertyGroupID] [int] NULL,
	[Text] [varchar](255) NOT NULL,
	[X] [int] NOT NULL,
	[Y] [int] NOT NULL,
	[Width] [int] NOT NULL,
	[Height] [int] NOT NULL,
 CONSTRAINT [PK_FCProjectCardObject] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCProjectCardObject]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCardObject_FCProjectCard] FOREIGN KEY([FCProjectCardID])
REFERENCES [dbo].[FCProjectCard] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCardObject] CHECK CONSTRAINT [FK_FCProjectCardObject_FCProjectCard]
GO
ALTER TABLE [dbo].[FCProjectCardObject]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCardObject_FCProjectProperty] FOREIGN KEY([FCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCardObject] CHECK CONSTRAINT [FK_FCProjectCardObject_FCProjectProperty]
GO
ALTER TABLE [dbo].[FCProjectCardObject]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCardObject_FCProjectPropertyGroup] FOREIGN KEY([FCProjectPropertyGroupID])
REFERENCES [dbo].[FCProjectPropertyGroup] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCardObject] CHECK CONSTRAINT [FK_FCProjectCardObject_FCProjectPropertyGroup]
GO
