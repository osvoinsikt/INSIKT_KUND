SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AISettings](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Deployment] [nvarchar](100) NOT NULL,
	[IsActiveConfig] [bit] NOT NULL,
	[Host] [nvarchar](255) NULL,
	[CompanyContext] [nvarchar](max) NULL,
	[InputCost] [decimal](18, 8) NOT NULL,
	[OutputCost] [decimal](18, 8) NOT NULL,
 CONSTRAINT [PK_AISettings_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[AISettings] ADD  CONSTRAINT [DF_AISettings_IsActiveConfig]  DEFAULT ((0)) FOR [IsActiveConfig]
GO
ALTER TABLE [dbo].[AISettings] ADD  CONSTRAINT [DF_AISettings_InputCost]  DEFAULT ((0)) FOR [InputCost]
GO
ALTER TABLE [dbo].[AISettings] ADD  CONSTRAINT [DF_AISettings_OutputCost]  DEFAULT ((0)) FOR [OutputCost]
GO
