SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSourcePerspectiveDisplayFolderRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourcePerspectiveID] [int] NOT NULL,
	[DisplayFolderPath] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_DataSourcePerspectiveDisplayFolderRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataSourcePerspectiveDisplayFolderRelation]  WITH CHECK ADD  CONSTRAINT [FK_DataSourcePerspectiveDisplayFolderRelation_Perspective] FOREIGN KEY([DataSourcePerspectiveID])
REFERENCES [dbo].[DataSourcePerspective] ([ID])
GO
ALTER TABLE [dbo].[DataSourcePerspectiveDisplayFolderRelation] CHECK CONSTRAINT [FK_DataSourcePerspectiveDisplayFolderRelation_Perspective]
GO
