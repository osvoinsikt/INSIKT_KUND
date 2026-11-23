SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Domain](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DomainName] [nvarchar](50) NULL,
	[FullyQualifiedDomainName] [nvarchar](100) NULL,
	[ProtocolTypeID] [int] NOT NULL,
	[UserName] [varchar](50) NULL,
	[Password] [nvarchar](max) NULL,
	[TenantID] [varchar](100) NULL,
	[ClientID] [varchar](100) NULL,
	[ClientSecret] [nvarchar](max) NULL,
	[DomainServer] [varchar](100) NULL,
	[SearchRoot] [nvarchar](100) NULL,
	[IsConfigurable] [bit] NOT NULL,
	[SyncEnabled] [bit] NOT NULL,
	[SearchEnabled] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[IsSecureLDAP] [bit] NOT NULL,
	[LastSuccessfulSync] [datetime] NULL,
 CONSTRAINT [PK_Domain] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Domain] ADD  CONSTRAINT [DF_Domain_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Domain] ADD  CONSTRAINT [DF_Domain_IsSecureLDAP]  DEFAULT ((0)) FOR [IsSecureLDAP]
GO
ALTER TABLE [dbo].[Domain]  WITH CHECK ADD  CONSTRAINT [FK_Domain_DomainProtocolType] FOREIGN KEY([ProtocolTypeID])
REFERENCES [dbo].[DomainProtocolType] ([ID])
GO
ALTER TABLE [dbo].[Domain] CHECK CONSTRAINT [FK_Domain_DomainProtocolType]
GO
