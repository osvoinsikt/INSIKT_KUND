SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCColumnDynamicChoice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Caption] [nvarchar](max) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[FCColumnID] [int] NOT NULL,
	[SortOrder] [int] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_FCColumnDynamicChoice] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCColumnDynamicChoice] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCColumnDynamicChoice]  WITH CHECK ADD  CONSTRAINT [FK_FCColumnDynamicChoice_FCColumns] FOREIGN KEY([FCColumnID])
REFERENCES [dbo].[FCColumns] ([ID])
GO
ALTER TABLE [dbo].[FCColumnDynamicChoice] CHECK CONSTRAINT [FK_FCColumnDynamicChoice_FCColumns]
GO
