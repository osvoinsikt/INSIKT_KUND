SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModuleGroup](
	[ID] [int] NOT NULL,
	[Caption] [nvarchar](30) NOT NULL,
	[SortOrder] [int] NOT NULL,
	[Icon] [nvarchar](max) NULL,
	[ShowIconOnly] [bit] NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_ModuleGroup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[ModuleGroup] ADD  CONSTRAINT [DF_ModuleGroup_ShowIconOnly]  DEFAULT ((0)) FOR [ShowIconOnly]
GO
ALTER TABLE [dbo].[ModuleGroup] ADD  CONSTRAINT [DF_ModuleGroup_Description]  DEFAULT ('') FOR [Description]
GO
