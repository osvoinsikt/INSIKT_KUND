SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[dim_Produkt - Grp_Produkttyp_2](
	[L0_ID] [int] NOT NULL,
	[L0_DisplayName] [nvarchar](500) NULL,
	[L0_Sort] [bigint] NOT NULL,
	[L1_ID] [int] NOT NULL,
	[L1_DisplayName] [nvarchar](500) NULL,
	[L1_Sort] [bigint] NOT NULL,
	[Produkt - Grp_Produkttyp_2_LeafID] [int] NOT NULL,
	[Grp_Produkttyp_2ID] [int] NOT NULL,
	[ProduktID] [int] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_dim_Produkt - Grp_Produkttyp_2] PRIMARY KEY CLUSTERED 
(
	[ProduktID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dw].[dim_Produkt - Grp_Produkttyp_2] ADD  DEFAULT (suser_name()) FOR [CreatedBy]
GO
ALTER TABLE [dw].[dim_Produkt - Grp_Produkttyp_2] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dw].[dim_Produkt - Grp_Produkttyp_2]  WITH CHECK ADD  CONSTRAINT [FK_dim_Produkt - Grp_Produkttyp_2_Grp_Produkttyp_2] FOREIGN KEY([Grp_Produkttyp_2ID])
REFERENCES [dw].[base_Grp_Produkttyp_2] ([Grp_Produkttyp_2ID])
GO
ALTER TABLE [dw].[dim_Produkt - Grp_Produkttyp_2] CHECK CONSTRAINT [FK_dim_Produkt - Grp_Produkttyp_2_Grp_Produkttyp_2]
GO
ALTER TABLE [dw].[dim_Produkt - Grp_Produkttyp_2]  WITH CHECK ADD  CONSTRAINT [FK_dim_Produkt - Grp_Produkttyp_2_Produkt] FOREIGN KEY([ProduktID])
REFERENCES [dw].[base_Produkt] ([ProduktID])
GO
ALTER TABLE [dw].[dim_Produkt - Grp_Produkttyp_2] CHECK CONSTRAINT [FK_dim_Produkt - Grp_Produkttyp_2_Produkt]
GO
