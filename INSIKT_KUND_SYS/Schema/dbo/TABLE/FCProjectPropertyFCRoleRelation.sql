SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectPropertyFCRoleRelation](
	[FCProjectPropertyID] [int] NOT NULL,
	[FCRoleID] [int] NOT NULL,
 CONSTRAINT [PK_FCProjectPropertyFCRoleRelation] PRIMARY KEY CLUSTERED 
(
	[FCProjectPropertyID] ASC,
	[FCRoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectPropertyFCRoleRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFCRoleRelation_FCProjectProperty] FOREIGN KEY([FCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFCRoleRelation] CHECK CONSTRAINT [FK_FCProjectPropertyFCRoleRelation_FCProjectProperty]
GO
ALTER TABLE [dbo].[FCProjectPropertyFCRoleRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyFCRoleRelation_FCRole] FOREIGN KEY([FCRoleID])
REFERENCES [dbo].[FCRole] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyFCRoleRelation] CHECK CONSTRAINT [FK_FCProjectPropertyFCRoleRelation_FCRole]
GO
