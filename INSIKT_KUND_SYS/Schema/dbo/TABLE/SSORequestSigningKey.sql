SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SSORequestSigningKey](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PrivateKey] [nvarchar](max) NOT NULL,
	[PrivateKeyPassphrase] [nvarchar](max) NULL,
	[Certificate] [nvarchar](max) NOT NULL,
	[AddedDate] [datetime] NOT NULL,
	[ValidUntil] [datetime] NOT NULL,
 CONSTRAINT [PK_SSORequestSigningKey] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
