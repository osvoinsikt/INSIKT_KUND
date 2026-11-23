SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCProjectPropertyDefaultValue](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProjectPropertyID] [int] NOT NULL,
	[ValueNumeric] [float] NULL,
	[ValueString] [varchar](3000) NULL,
 CONSTRAINT [PK_FCProjectPropertyDefaultValue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCProjectPropertyDefaultValue]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyDefaultValue_FCProjectProperty] FOREIGN KEY([ProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyDefaultValue] CHECK CONSTRAINT [FK_FCProjectPropertyDefaultValue_FCProjectProperty]
GO
