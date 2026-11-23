SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Integration](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IntegrationSystemTypeID] [int] NOT NULL,
	[ApiKey] [varchar](300) NULL,
	[Enabled] [bit] NOT NULL,
 CONSTRAINT [PK_Integration_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Integration]  WITH CHECK ADD  CONSTRAINT [FK_Integration_IntegrationSystemType] FOREIGN KEY([IntegrationSystemTypeID])
REFERENCES [dbo].[IntegrationSystemType] ([ID])
GO
ALTER TABLE [dbo].[Integration] CHECK CONSTRAINT [FK_Integration_IntegrationSystemType]
GO
