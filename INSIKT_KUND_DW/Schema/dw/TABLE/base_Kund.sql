SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[base_Kund](
	[KundID] [int] IDENTITY(1,1) NOT NULL,
	[Grp Kundprisgrupp 1ID] [int] NOT NULL,
	[Code] [int] NULL,
	[Name] [nvarchar](100) NOT NULL,
	[DisplayName] [nvarchar](150) NOT NULL,
	[DisabledAt] [datetime] NULL,
	[IsDisabled] [bit] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_dw_base_Kund] PRIMARY KEY CLUSTERED 
(
	[KundID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dw_base_Kund] ON [dw].[base_Kund]
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dw].[base_Kund] ADD  DEFAULT ((0)) FOR [IsDisabled]
GO
ALTER TABLE [dw].[base_Kund] ADD  DEFAULT (suser_name()) FOR [CreatedBy]
GO
ALTER TABLE [dw].[base_Kund] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dw].[base_Kund] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dw].[base_Kund]  WITH CHECK ADD  CONSTRAINT [FK_dw_base_Kund_Grp Kundprisgrupp 1] FOREIGN KEY([Grp Kundprisgrupp 1ID])
REFERENCES [dw].[base_Grp Kundprisgrupp 1] ([Grp Kundprisgrupp 1ID])
GO
ALTER TABLE [dw].[base_Kund] CHECK CONSTRAINT [FK_dw_base_Kund_Grp Kundprisgrupp 1]
GO
