SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LangDictionary](
	[ControlName] [nvarchar](100) NOT NULL,
	[LangID] [int] NOT NULL,
	[VisibleName] [nvarchar](max) NOT NULL,
	[CustomName] [nvarchar](max) NULL,
	[Comment] [nvarchar](max) NULL,
	[FCTypeID] [int] NULL,
	[FCObjectTypeID] [int] NULL,
 CONSTRAINT [UQ_LangDictionary] UNIQUE NONCLUSTERED 
(
	[ControlName] ASC,
	[LangID] ASC,
	[FCTypeID] ASC,
	[FCObjectTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[LangDictionary]  WITH CHECK ADD  CONSTRAINT [FK_LangDictionary_Language] FOREIGN KEY([LangID])
REFERENCES [dbo].[Language] ([ID])
GO
ALTER TABLE [dbo].[LangDictionary] CHECK CONSTRAINT [FK_LangDictionary_Language]
GO
