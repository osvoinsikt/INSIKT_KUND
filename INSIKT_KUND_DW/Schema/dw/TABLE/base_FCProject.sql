SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[base_FCProject](
	[FCProjectID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](100) NOT NULL,
	[DisplayName] [nvarchar](150) NOT NULL,
	[ProjektID] [int] NULL,
	[StartDateID] [int] NULL,
	[EndDateID] [int] NULL,
	[StartMonthID] [int] NULL,
	[EndMonthID] [int] NULL,
	[Projektledare] [nvarchar](300) NULL,
	[Projektstatus] [nvarchar](300) NULL,
	[Projekttyp] [nvarchar](300) NULL,
	[Projektfas] [nvarchar](300) NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_dw_base_FCProject] PRIMARY KEY CLUSTERED 
(
	[FCProjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dw].[base_FCProject] ADD  CONSTRAINT [DF__base_FCPr__Creat__23F3538A]  DEFAULT (suser_name()) FOR [CreatedBy]
GO
ALTER TABLE [dw].[base_FCProject] ADD  CONSTRAINT [DF__base_FCPr__Creat__24E777C3]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dw].[base_FCProject] ADD  CONSTRAINT [DF__base_FCPr__IsDel__25DB9BFC]  DEFAULT ((0)) FOR [IsDeleted]
GO
