SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Geography](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Caption] [varchar](250) NULL,
	[Definition] [geography] NOT NULL,
	[Center] [geography] NULL,
	[GeographyTypeID] [int] NOT NULL,
	[MinZoomLevel] [float] NULL,
	[MaxZoomLevel] [float] NULL,
	[SourceID] [varchar](100) NULL,
 CONSTRAINT [PK_Geography] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Geography]  WITH CHECK ADD  CONSTRAINT [FK_Geography_GeographyType] FOREIGN KEY([GeographyTypeID])
REFERENCES [dbo].[GeographyType] ([ID])
GO
ALTER TABLE [dbo].[Geography] CHECK CONSTRAINT [FK_Geography_GeographyType]
GO
