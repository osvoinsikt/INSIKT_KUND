SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCViewDimensionCustomRow](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCViewDimensionID] [int] NOT NULL,
	[ElementKey] [nvarchar](50) NULL,
	[UniqueName] [nvarchar](255) NULL,
	[Description] [varchar](255) NULL,
	[Order] [int] NULL,
 CONSTRAINT [PK_FCViewDimensionCustomRow] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCViewDimensionCustomRow]  WITH CHECK ADD  CONSTRAINT [FK_FCViewDimensionCustomRow_FCViewDimension] FOREIGN KEY([FCViewDimensionID])
REFERENCES [dbo].[FCViewDimension] ([ID])
GO
ALTER TABLE [dbo].[FCViewDimensionCustomRow] CHECK CONSTRAINT [FK_FCViewDimensionCustomRow_FCViewDimension]
GO
