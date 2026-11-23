SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SharePointCertificate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Password] [nvarchar](1000) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[PfxFile] [varbinary](max) NOT NULL,
	[CertificateTypeID] [int] NOT NULL,
 CONSTRAINT [PK_SharePointCertificate] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[SharePointCertificate]  WITH CHECK ADD  CONSTRAINT [FK_SharePointCertificate_CertificateType] FOREIGN KEY([CertificateTypeID])
REFERENCES [dbo].[SharePointCertificateType] ([ID])
GO
ALTER TABLE [dbo].[SharePointCertificate] CHECK CONSTRAINT [FK_SharePointCertificate_CertificateType]
GO
