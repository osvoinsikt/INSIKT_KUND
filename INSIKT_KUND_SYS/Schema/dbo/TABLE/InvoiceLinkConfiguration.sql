SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InvoiceLinkConfiguration](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceLinkTypeID] [int] NOT NULL,
	[PathToInvoiceRoot] [varchar](1000) NULL,
	[InvoiceFileType] [varchar](5) NULL,
	[UseImpersonationWhenFetchingInvoice] [bit] NULL,
	[UserNameToFetchInvoiceWith] [varchar](255) NULL,
	[DomainToFetchInvoiceWith] [varchar](255) NULL,
	[PasswordToFetchInvoiceWith] [varchar](500) NULL,
	[UseAsRemoteCredentials] [bit] NULL,
	[PathToXSLFile] [nvarchar](max) NULL,
	[IsDefault] [bit] NOT NULL,
	[DownloadAllLimit] [int] NULL,
 CONSTRAINT [PK_InvoiceLinkConfiguration] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[InvoiceLinkConfiguration] ADD  CONSTRAINT [DF_InvoiceLinkConfiguration_IsDefault]  DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[InvoiceLinkConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceLinkConfiguration_InvoiceLinkType] FOREIGN KEY([InvoiceLinkTypeID])
REFERENCES [dbo].[InvoiceLinkType] ([ID])
GO
ALTER TABLE [dbo].[InvoiceLinkConfiguration] CHECK CONSTRAINT [FK_InvoiceLinkConfiguration_InvoiceLinkType]
GO
