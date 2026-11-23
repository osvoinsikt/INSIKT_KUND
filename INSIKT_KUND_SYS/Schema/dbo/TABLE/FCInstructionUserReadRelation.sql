SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCInstructionUserReadRelation](
	[FCInstructionID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
 CONSTRAINT [PK_FCInstructionUserReadRelation] PRIMARY KEY CLUSTERED 
(
	[FCInstructionID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCInstructionUserReadRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCInstructionUserReadRelation_FCInstructionID_FCInstruction] FOREIGN KEY([FCInstructionID])
REFERENCES [dbo].[FCInstruction] ([ID])
GO
ALTER TABLE [dbo].[FCInstructionUserReadRelation] CHECK CONSTRAINT [FK_FCInstructionUserReadRelation_FCInstructionID_FCInstruction]
GO
ALTER TABLE [dbo].[FCInstructionUserReadRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCInstructionUserReadRelation_UserID_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCInstructionUserReadRelation] CHECK CONSTRAINT [FK_FCInstructionUserReadRelation_UserID_UserSecurityGroup]
GO
