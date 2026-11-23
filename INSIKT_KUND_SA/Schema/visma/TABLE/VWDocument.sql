SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [visma].[VWDocument](
	[DocumentId] [int] NOT NULL,
	[Description] [varchar](100) NULL,
	[SupplierId] [int] NULL,
	[OriginInfo] [varchar](255) NULL,
	[OriginDescription] [varchar](255) NULL,
	[DueDate] [datetime] NULL,
	[Status] [int] NULL,
	[AccountingStatus] [int] NULL,
	[CurrencyAmount] [decimal](28, 6) NULL,
	[CurrencyNo] [int] NULL,
	[CurrencyRate] [decimal](28, 6) NULL,
	[CurrencyRateUnit] [int] NOT NULL,
	[Amount] [decimal](28, 6) NOT NULL,
	[VatAmount] [decimal](28, 6) NOT NULL,
	[CID] [nvarchar](100) NULL,
	[AccountingRuleId] [int] NULL,
	[DocumentType] [int] NULL,
	[OrganizationNumber] [varchar](50) NULL,
	[BankAccount] [varchar](35) NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceNo] [varchar](25) NULL,
	[BatchNo] [int] NULL,
	[VoucherNo] [int] NULL,
	[RowVersionNo] [int] NOT NULL,
	[Created] [datetime] NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[LastUpdate] [datetime] NOT NULL,
	[LastUpdatedBy] [varchar](100) NULL,
	[DocumentCategory] [int] NOT NULL,
	[SourceSystemId] [varchar](48) NOT NULL,
	[Deadline] [datetime] NULL,
	[ODHandle] [varchar](255) NULL,
	[BookingPeriod] [nvarchar](100) NULL,
	[InvoiceReference] [nvarchar](50) NULL,
	[RoundingAmount] [decimal](28, 6) NOT NULL,
	[DocumentNoteCategory] [int] NOT NULL,
	[OrderNumber] [varchar](100) NULL,
	[SA_SourceSystemID] [int] NOT NULL,
 CONSTRAINT [PK_visma_VWDocument] PRIMARY KEY CLUSTERED 
(
	[SA_SourceSystemID] ASC,
	[DocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
