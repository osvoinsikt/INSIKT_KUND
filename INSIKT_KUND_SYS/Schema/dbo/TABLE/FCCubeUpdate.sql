SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCCubeUpdate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ASServer] [varchar](50) NOT NULL,
	[ASDatabase] [varchar](50) NOT NULL,
	[MDXQuery] [nvarchar](max) NOT NULL,
	[UserID] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
	[isCommited] [bit] NOT NULL,
	[UpdateFailed] [bit] NOT NULL,
	[CommitFailed] [bit] NOT NULL,
	[CommitDate] [datetime] NULL,
 CONSTRAINT [PK_FCCubeUpdate] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCCubeUpdate] ADD  CONSTRAINT [DF_FCCubeUpdate_Failed]  DEFAULT ((0)) FOR [UpdateFailed]
GO
ALTER TABLE [dbo].[FCCubeUpdate] ADD  CONSTRAINT [DF_FCCubeUpdate_CommitFailed]  DEFAULT ((0)) FOR [CommitFailed]
GO
