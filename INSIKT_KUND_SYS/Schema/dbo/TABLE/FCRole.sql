SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCRole](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RoleTypeID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](255) NULL,
	[Order] [int] NULL,
	[SortOrder] [int] NULL,
 CONSTRAINT [PK_FCRole] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCRole]  WITH CHECK ADD  CONSTRAINT [FK_FCRole_FCRoleType] FOREIGN KEY([RoleTypeID])
REFERENCES [dbo].[FCRoleType] ([ID])
GO
ALTER TABLE [dbo].[FCRole] CHECK CONSTRAINT [FK_FCRole_FCRoleType]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Bestämmer vilken ordning/nivå som rollen har. T.ex Order = 1 på Approver betyder Första Godkännare' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCRole', @level2type=N'COLUMN',@level2name=N'Order'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sorteringsordning på roller. T.ex vilken ordning de visas i gränssnittet.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCRole', @level2type=N'COLUMN',@level2name=N'SortOrder'
GO
