SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserFCTypeRelation](
	[UserID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[DenyAccess] [bit] NOT NULL,
	[DenyEditing] [bit] NOT NULL,
 CONSTRAINT [PK_UserFCTypeRelation] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[FCTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserFCTypeRelation] ADD  CONSTRAINT [DF_UserFCTypeRelation_DenyAccess]  DEFAULT ((0)) FOR [DenyAccess]
GO
ALTER TABLE [dbo].[UserFCTypeRelation] ADD  CONSTRAINT [DF_UserFCTypeRelation_DenyEditing]  DEFAULT ((0)) FOR [DenyEditing]
GO
ALTER TABLE [dbo].[UserFCTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserFCTypeRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[UserFCTypeRelation] CHECK CONSTRAINT [FK_UserFCTypeRelation_FCType]
GO
ALTER TABLE [dbo].[UserFCTypeRelation]  WITH CHECK ADD  CONSTRAINT [FK_UserFCTypeRelation_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserFCTypeRelation] CHECK CONSTRAINT [FK_UserFCTypeRelation_UserSecurityGroup]
GO
