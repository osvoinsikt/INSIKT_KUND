SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[base_Projekt](
	[ProjektID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [int] NULL,
	[Name] [nvarchar](100) NOT NULL,
	[DisplayName] [nvarchar](150) NOT NULL,
	[DisabledAt] [datetime] NULL,
	[IsDisabled] [bit] NOT NULL,
	[ParentCode] [int] NULL,
	[ParentProjektID] [int] NULL,
	[IsParent] [bit] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_dw_base_Projekt] PRIMARY KEY CLUSTERED 
(
	[ProjektID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dw_base_Projekt] ON [dw].[base_Projekt]
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dw].[base_Projekt] ADD  DEFAULT ((0)) FOR [IsDisabled]
GO
ALTER TABLE [dw].[base_Projekt] ADD  DEFAULT ((0)) FOR [IsParent]
GO
ALTER TABLE [dw].[base_Projekt] ADD  DEFAULT (suser_name()) FOR [CreatedBy]
GO
ALTER TABLE [dw].[base_Projekt] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dw].[base_Projekt] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
