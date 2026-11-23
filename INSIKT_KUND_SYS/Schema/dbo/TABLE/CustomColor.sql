SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomColor](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UsageTypeID] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Color0] [varchar](7) NULL,
	[Color1] [varchar](7) NULL,
	[Color2] [varchar](7) NULL,
	[Color3] [varchar](7) NULL,
	[Color4] [varchar](7) NULL,
	[Color5] [varchar](7) NULL,
	[Color6] [varchar](7) NULL,
	[Color7] [varchar](7) NULL,
	[Color8] [varchar](7) NULL,
 CONSTRAINT [PK_dbo_CustomColor] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[CustomColor]  WITH CHECK ADD  CONSTRAINT [FK_CustomColor_UsageType] FOREIGN KEY([UsageTypeID])
REFERENCES [dbo].[CustomColorUsageType] ([ID])
GO
ALTER TABLE [dbo].[CustomColor] CHECK CONSTRAINT [FK_CustomColor_UsageType]
GO
