SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dw].[base_Produkt](
	[ProduktID] [int] IDENTITY(1,1) NOT NULL,
	[Grp Produktprisgrupp 1ID] [int] NOT NULL,
	[Grp_Produkttyp_1ID] [int] NOT NULL,
	[Grp_Produkttyp_2ID] [int] NOT NULL,
	[Code] [varchar](40) NULL,
	[Name] [nvarchar](100) NOT NULL,
	[DisplayName] [nvarchar](150) NOT NULL,
	[DisabledAt] [datetime] NULL,
	[IsDisabled] [bit] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_dw_base_Produkt] PRIMARY KEY CLUSTERED 
(
	[ProduktID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dw_base_Produkt] ON [dw].[base_Produkt]
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dw].[base_Produkt] ADD  DEFAULT ((0)) FOR [IsDisabled]
GO
ALTER TABLE [dw].[base_Produkt] ADD  DEFAULT (suser_name()) FOR [CreatedBy]
GO
ALTER TABLE [dw].[base_Produkt] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dw].[base_Produkt] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dw].[base_Produkt]  WITH CHECK ADD  CONSTRAINT [FK_dw_base_Produkt_Grp Produktprisgrupp 1] FOREIGN KEY([Grp Produktprisgrupp 1ID])
REFERENCES [dw].[base_Grp Produktprisgrupp 1] ([Grp Produktprisgrupp 1ID])
GO
ALTER TABLE [dw].[base_Produkt] CHECK CONSTRAINT [FK_dw_base_Produkt_Grp Produktprisgrupp 1]
GO
ALTER TABLE [dw].[base_Produkt]  WITH CHECK ADD  CONSTRAINT [FK_dw_base_Produkt_Grp_Produkttyp_1] FOREIGN KEY([Grp_Produkttyp_1ID])
REFERENCES [dw].[base_Grp_Produkttyp_1] ([Grp_Produkttyp_1ID])
GO
ALTER TABLE [dw].[base_Produkt] CHECK CONSTRAINT [FK_dw_base_Produkt_Grp_Produkttyp_1]
GO
ALTER TABLE [dw].[base_Produkt]  WITH CHECK ADD  CONSTRAINT [FK_dw_base_Produkt_Grp_Produkttyp_2] FOREIGN KEY([Grp_Produkttyp_2ID])
REFERENCES [dw].[base_Grp_Produkttyp_2] ([Grp_Produkttyp_2ID])
GO
ALTER TABLE [dw].[base_Produkt] CHECK CONSTRAINT [FK_dw_base_Produkt_Grp_Produkttyp_2]
GO
