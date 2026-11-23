SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[dim_Kassa](
	[L0_ID] [int] NOT NULL,
	[L0_DisplayName] [nvarchar](500) NULL,
	[L0_Sort] [bigint] NOT NULL,
	[L1_ID] [int] NOT NULL,
	[L1_DisplayName] [nvarchar](500) NULL,
	[L1_Sort] [bigint] NOT NULL,
	[L2_ID] [int] NOT NULL,
	[L2_DisplayName] [nvarchar](500) NULL,
	[L2_Sort] [bigint] NOT NULL,
	[L3_ID] [int] NOT NULL,
	[L3_DisplayName] [nvarchar](500) NULL,
	[L3_Sort] [bigint] NOT NULL,
	[L4_ID] [int] NOT NULL,
	[L4_DisplayName] [nvarchar](500) NULL,
	[L4_Sort] [bigint] NOT NULL,
	[Kassa_LeafID] [int] NOT NULL,
	[Kassa_DisplayName] [nvarchar](150) NULL,
	[Kassa_Sort] [nvarchar](150) NULL,
	[KassaID] [int] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_dim_Kassa] PRIMARY KEY CLUSTERED 
(
	[KassaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dw].[dim_Kassa] ADD  DEFAULT (suser_name()) FOR [CreatedBy]
GO
ALTER TABLE [dw].[dim_Kassa] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dw].[dim_Kassa]  WITH CHECK ADD  CONSTRAINT [FK_dim_Kassa_Kassa] FOREIGN KEY([KassaID])
REFERENCES [dw].[base_Kassa] ([KassaID])
GO
ALTER TABLE [dw].[dim_Kassa] CHECK CONSTRAINT [FK_dim_Kassa_Kassa]
GO
