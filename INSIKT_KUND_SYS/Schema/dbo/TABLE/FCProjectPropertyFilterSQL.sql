SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectPropertyFilterSQL](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectPropertyFilterPartID] [int] NOT NULL,
	[SQL] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_FCProjectPropertyFilterSQL] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectPropertyFilterSQL]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFilterSQL_FCProjectPropertyFilterPartID] FOREIGN KEY([FCProjectPropertyFilterPartID])
REFERENCES [dbo].[FCProjectPropertyFilterPart] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFilterSQL] CHECK CONSTRAINT [FK_FCProjectPropertyFilterSQL_FCProjectPropertyFilterPartID]
GO
