SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectPropertyGroup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](200) NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[SortOrder] [int] NULL,
	[ShowTitlePropertyNames] [bit] NOT NULL,
	[IsReadOnly] [bit] NOT NULL,
	[QueryToSetReadOnly] [nvarchar](max) NULL,
 CONSTRAINT [PK_FCProjectPropertyGroup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectPropertyGroup] ADD  CONSTRAINT [DF_FCProjectPropertyGroup_ShowTitlePropertyNames]  DEFAULT ((1)) FOR [ShowTitlePropertyNames]
GO
ALTER TABLE [dbo].[FCProjectPropertyGroup] ADD  CONSTRAINT [DF_FCProjectPropertyGroup_IsReadOnly]  DEFAULT ((0)) FOR [IsReadOnly]
GO
