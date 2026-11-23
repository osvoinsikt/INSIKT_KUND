SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[dim_Produkt - Grp Produktprisgrupp 1](
	[L0_ID] [int] NOT NULL,
	[L0_DisplayName] [nvarchar](500) NULL,
	[L0_Sort] [bigint] NOT NULL,
	[L1_ID] [int] NOT NULL,
	[L1_DisplayName] [nvarchar](500) NULL,
	[L1_Sort] [bigint] NOT NULL,
	[Produkt - Grp Produktprisgrupp 1_LeafID] [int] NOT NULL,
	[Grp Produktprisgrupp 1ID] [int] NOT NULL,
	[ProduktID] [int] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_dim_Produkt - Grp Produktprisgrupp 1] PRIMARY KEY CLUSTERED 
(
	[ProduktID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dw].[dim_Produkt - Grp Produktprisgrupp 1] ADD  DEFAULT (suser_name()) FOR [CreatedBy]
GO
ALTER TABLE [dw].[dim_Produkt - Grp Produktprisgrupp 1] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dw].[dim_Produkt - Grp Produktprisgrupp 1]  WITH CHECK ADD  CONSTRAINT [FK_dim_Produkt - Grp Produktprisgrupp 1_Grp Produktprisgrupp 1] FOREIGN KEY([Grp Produktprisgrupp 1ID])
REFERENCES [dw].[base_Grp Produktprisgrupp 1] ([Grp Produktprisgrupp 1ID])
GO
ALTER TABLE [dw].[dim_Produkt - Grp Produktprisgrupp 1] CHECK CONSTRAINT [FK_dim_Produkt - Grp Produktprisgrupp 1_Grp Produktprisgrupp 1]
GO
ALTER TABLE [dw].[dim_Produkt - Grp Produktprisgrupp 1]  WITH CHECK ADD  CONSTRAINT [FK_dim_Produkt - Grp Produktprisgrupp 1_Produkt] FOREIGN KEY([ProduktID])
REFERENCES [dw].[base_Produkt] ([ProduktID])
GO
ALTER TABLE [dw].[dim_Produkt - Grp Produktprisgrupp 1] CHECK CONSTRAINT [FK_dim_Produkt - Grp Produktprisgrupp 1_Produkt]
GO
