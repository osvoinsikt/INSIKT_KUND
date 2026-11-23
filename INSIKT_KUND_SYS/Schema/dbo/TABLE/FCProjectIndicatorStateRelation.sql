SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectIndicatorStateRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectIndicatorID] [int] NOT NULL,
	[FCProjectID] [int] NOT NULL,
	[FCProjectIndicatorStateID] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[ModifiedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[Comment] [nvarchar](max) NULL,
	[IsCurrentState] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectIndicatorStateRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectIndicatorStateRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectIndicatorStateRelation_FCProject] FOREIGN KEY([FCProjectID])
REFERENCES [dbo].[FCProject] ([ID])
GO
ALTER TABLE [dbo].[FCProjectIndicatorStateRelation] CHECK CONSTRAINT [FK_FCProjectIndicatorStateRelation_FCProject]
GO
ALTER TABLE [dbo].[FCProjectIndicatorStateRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectIndicatorStateRelation_FCProjectIndicator] FOREIGN KEY([FCProjectIndicatorID])
REFERENCES [dbo].[FCProjectIndicator] ([ID])
GO
ALTER TABLE [dbo].[FCProjectIndicatorStateRelation] CHECK CONSTRAINT [FK_FCProjectIndicatorStateRelation_FCProjectIndicator]
GO
ALTER TABLE [dbo].[FCProjectIndicatorStateRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectIndicatorStateRelation_FCProjectIndicatorState] FOREIGN KEY([FCProjectIndicatorStateID])
REFERENCES [dbo].[FCProjectIndicatorState] ([ID])
GO
ALTER TABLE [dbo].[FCProjectIndicatorStateRelation] CHECK CONSTRAINT [FK_FCProjectIndicatorStateRelation_FCProjectIndicatorState]
GO
ALTER TABLE [dbo].[FCProjectIndicatorStateRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectIndicatorStateRelation_UserSecurityGroup] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProjectIndicatorStateRelation] CHECK CONSTRAINT [FK_FCProjectIndicatorStateRelation_UserSecurityGroup]
GO
ALTER TABLE [dbo].[FCProjectIndicatorStateRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectIndicatorStateRelation_UserSecurityGroup_2] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProjectIndicatorStateRelation] CHECK CONSTRAINT [FK_FCProjectIndicatorStateRelation_UserSecurityGroup_2]
GO
