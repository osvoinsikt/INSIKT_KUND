SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VersionSupportStatus](
	[Major] [int] NOT NULL,
	[Minor] [int] NOT NULL,
	[Status] [varchar](20) NULL,
	[EndOfSupportDate] [datetime] NULL,
	[CreatedAt] [datetime] NULL,
 CONSTRAINT [PK_VersionSupportStatus_MajorMinor] PRIMARY KEY CLUSTERED 
(
	[Major] ASC,
	[Minor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[VersionSupportStatus] ADD  CONSTRAINT [DF_VersionSupportStatus_CreatedAt]  DEFAULT (getutcdate()) FOR [CreatedAt]
GO
