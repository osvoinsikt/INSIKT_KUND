SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SharePointPropertiesRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectPropertyID] [int] NOT NULL,
	[PropertyName] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_SharePointPropertiesRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[SharePointPropertiesRelation]  WITH CHECK ADD  CONSTRAINT [FK_SharePointPropertiesRelation_FCProjectProperty] FOREIGN KEY([FCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[SharePointPropertiesRelation] CHECK CONSTRAINT [FK_SharePointPropertiesRelation_FCProjectProperty]
GO
