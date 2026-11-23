SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectViewLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[UserID] [int] NOT NULL,
	[RunningAsUserID] [int] NULL,
	[FCObjectTypeID] [int] NOT NULL,
	[FCTypeID] [int] NULL,
	[MemberUniqueName] [nvarchar](255) NULL,
	[MemberCaption] [nvarchar](255) NULL,
	[FCVersionID] [int] NULL,
	[FCVersionName] [nvarchar](255) NULL,
 CONSTRAINT [PK_FCObjectViewLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
