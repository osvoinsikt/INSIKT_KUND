SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[dim_Kund - Grp Kundprisgrupp 1](
	[L0_ID] [int] NOT NULL,
	[L0_DisplayName] [nvarchar](500) NULL,
	[L0_Sort] [bigint] NOT NULL,
	[L1_ID] [int] NOT NULL,
	[L1_DisplayName] [nvarchar](500) NULL,
	[L1_Sort] [bigint] NOT NULL,
	[Kund - Grp Kundprisgrupp 1_LeafID] [int] NOT NULL,
	[Grp Kundprisgrupp 1ID] [int] NOT NULL,
	[KundID] [int] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_dim_Kund - Grp Kundprisgrupp 1] PRIMARY KEY CLUSTERED 
(
	[KundID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dw].[dim_Kund - Grp Kundprisgrupp 1] ADD  DEFAULT (suser_name()) FOR [CreatedBy]
GO
ALTER TABLE [dw].[dim_Kund - Grp Kundprisgrupp 1] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dw].[dim_Kund - Grp Kundprisgrupp 1]  WITH CHECK ADD  CONSTRAINT [FK_dim_Kund - Grp Kundprisgrupp 1_Grp Kundprisgrupp 1] FOREIGN KEY([Grp Kundprisgrupp 1ID])
REFERENCES [dw].[base_Grp Kundprisgrupp 1] ([Grp Kundprisgrupp 1ID])
GO
ALTER TABLE [dw].[dim_Kund - Grp Kundprisgrupp 1] CHECK CONSTRAINT [FK_dim_Kund - Grp Kundprisgrupp 1_Grp Kundprisgrupp 1]
GO
ALTER TABLE [dw].[dim_Kund - Grp Kundprisgrupp 1]  WITH CHECK ADD  CONSTRAINT [FK_dim_Kund - Grp Kundprisgrupp 1_Kund] FOREIGN KEY([KundID])
REFERENCES [dw].[base_Kund] ([KundID])
GO
ALTER TABLE [dw].[dim_Kund - Grp Kundprisgrupp 1] CHECK CONSTRAINT [FK_dim_Kund - Grp Kundprisgrupp 1_Kund]
GO
