SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSourcePerspective](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[DataSourceID] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_DataSourcePerspective] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataSourcePerspective] ADD  CONSTRAINT [DSP_IsDeleted_Default_Zero]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[DataSourcePerspective]  WITH CHECK ADD  CONSTRAINT [FK_DataSourcePerspective_DataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DataSources] ([ID])
GO
ALTER TABLE [dbo].[DataSourcePerspective] CHECK CONSTRAINT [FK_DataSourcePerspective_DataSource]
GO
