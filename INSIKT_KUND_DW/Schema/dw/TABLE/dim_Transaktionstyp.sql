SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[dim_Transaktionstyp](
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
	[Transaktionstyp_LeafID] [int] NOT NULL,
	[Transaktionstyp_DisplayName] [nvarchar](150) NULL,
	[Transaktionstyp_Sort] [nvarchar](150) NULL,
	[TransaktionstypID] [int] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_dim_Transaktionstyp] PRIMARY KEY CLUSTERED 
(
	[TransaktionstypID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dw].[dim_Transaktionstyp] ADD  DEFAULT (suser_name()) FOR [CreatedBy]
GO
ALTER TABLE [dw].[dim_Transaktionstyp] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dw].[dim_Transaktionstyp]  WITH CHECK ADD  CONSTRAINT [FK_dim_Transaktionstyp_Transaktionstyp] FOREIGN KEY([TransaktionstypID])
REFERENCES [dw].[base_Transaktionstyp] ([TransaktionstypID])
GO
ALTER TABLE [dw].[dim_Transaktionstyp] CHECK CONSTRAINT [FK_dim_Transaktionstyp_Transaktionstyp]
GO
