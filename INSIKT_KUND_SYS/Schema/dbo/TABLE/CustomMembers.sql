SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomMembers](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL,
	[CreatedBy] [int] NULL,
	[Dimension] [nvarchar](255) NOT NULL,
	[Hierarchy] [nvarchar](255) NOT NULL,
	[Function] [int] NULL,
	[Cube] [nvarchar](255) NOT NULL,
	[IsCommon] [bit] NULL,
	[MDXFormula] [nvarchar](max) NULL,
	[FormatString] [xml] NULL,
	[PositionReferenceMember] [nvarchar](1000) NULL,
	[Database] [nvarchar](255) NOT NULL,
	[DisplayFolder] [varchar](255) NULL,
	[SolveOrder] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
	[IsAlwaysAvailable] [bit] NOT NULL,
 CONSTRAINT [PK_CustomMembers] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[CustomMembers]  WITH CHECK ADD  CONSTRAINT [FK_CustomMembers_CustomMemberFunctions] FOREIGN KEY([Function])
REFERENCES [dbo].[CustomMemberFunctions] ([ID])
GO
ALTER TABLE [dbo].[CustomMembers] CHECK CONSTRAINT [FK_CustomMembers_CustomMemberFunctions]
GO
ALTER TABLE [dbo].[CustomMembers]  WITH CHECK ADD  CONSTRAINT [FK_CustomMembers_UserSecurityGroup] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[CustomMembers] CHECK CONSTRAINT [FK_CustomMembers_UserSecurityGroup]
GO
ALTER TABLE [dbo].[CustomMembers]  WITH CHECK ADD  CONSTRAINT [FK_CustomMembers_UserSecurityGroup_2] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[CustomMembers] CHECK CONSTRAINT [FK_CustomMembers_UserSecurityGroup_2]
GO
