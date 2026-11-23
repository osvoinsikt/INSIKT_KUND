SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [insikt].[FCProjectPropertyEventRelation](
	[FCProjectEventID] [int] NOT NULL,
	[FCProjectPropertyID] [int] NOT NULL,
 CONSTRAINT [PK_FCProjectPropertyEventRelation_1] PRIMARY KEY CLUSTERED 
(
	[FCProjectEventID] ASC,
	[FCProjectPropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [insikt].[FCProjectPropertyEventRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyEventRelation_FCProjectEvent] FOREIGN KEY([FCProjectEventID])
REFERENCES [insikt].[FCProjectEvent] ([FCProjectEventID])
GO
ALTER TABLE [insikt].[FCProjectPropertyEventRelation] CHECK CONSTRAINT [FK_FCProjectPropertyEventRelation_FCProjectEvent]
GO
