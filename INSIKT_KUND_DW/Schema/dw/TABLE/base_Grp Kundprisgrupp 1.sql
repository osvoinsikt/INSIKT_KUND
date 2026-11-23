SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dw].[base_Grp Kundprisgrupp 1](
	[Grp Kundprisgrupp 1ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](8) NULL,
	[Name] [nvarchar](100) NOT NULL,
	[DisplayName] [nvarchar](150) NOT NULL,
	[DisabledAt] [datetime] NULL,
	[IsDisabled] [bit] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_dw_base_Grp Kundprisgrupp 1] PRIMARY KEY CLUSTERED 
(
	[Grp Kundprisgrupp 1ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dw_base_Grp Kundprisgrupp 1] ON [dw].[base_Grp Kundprisgrupp 1]
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dw].[base_Grp Kundprisgrupp 1] ADD  DEFAULT ((0)) FOR [IsDisabled]
GO
ALTER TABLE [dw].[base_Grp Kundprisgrupp 1] ADD  DEFAULT (suser_name()) FOR [CreatedBy]
GO
ALTER TABLE [dw].[base_Grp Kundprisgrupp 1] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dw].[base_Grp Kundprisgrupp 1] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
