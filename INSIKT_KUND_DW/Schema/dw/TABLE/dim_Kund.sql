SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[dim_Kund](
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
	[Kund_LeafID] [int] NOT NULL,
	[Kund_DisplayName] [nvarchar](150) NULL,
	[Kund_Sort] [nvarchar](150) NULL,
	[KundID] [int] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_dim_Kund] PRIMARY KEY CLUSTERED 
(
	[KundID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dw].[dim_Kund] ADD  DEFAULT (suser_name()) FOR [CreatedBy]
GO
ALTER TABLE [dw].[dim_Kund] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dw].[dim_Kund]  WITH CHECK ADD  CONSTRAINT [FK_dim_Kund_Kund] FOREIGN KEY([KundID])
REFERENCES [dw].[base_Kund] ([KundID])
GO
ALTER TABLE [dw].[dim_Kund] CHECK CONSTRAINT [FK_dim_Kund_Kund]
GO
