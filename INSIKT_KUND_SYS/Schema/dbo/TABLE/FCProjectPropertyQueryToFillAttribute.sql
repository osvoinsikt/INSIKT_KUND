SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectPropertyQueryToFillAttribute](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectPropertyID] [int] NOT NULL,
	[Caption] [nvarchar](max) NOT NULL,
	[QueryToFillAttributes] [nvarchar](max) NOT NULL,
	[SortOrder] [int] NULL,
 CONSTRAINT [PK_FCProjectPropertyQueryToFillAttribute] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectPropertyQueryToFillAttribute]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyQueryToFillAttribute_FCProjectProperty] FOREIGN KEY([FCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyQueryToFillAttribute] CHECK CONSTRAINT [FK_FCProjectPropertyQueryToFillAttribute_FCProjectProperty]
GO
