SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectCalcProcess](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectID] [int] NOT NULL,
	[FCVersionID] [int] NOT NULL,
	[CurrentStepID] [int] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[ModifiedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[LastGeneratedTransactionID] [int] NOT NULL,
 CONSTRAINT [PK_FCProjetCalcProcess] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectCalcProcess] ADD  CONSTRAINT [DF_FCProjectCalcProcess_LastGeneratedTransactionID]  DEFAULT ((0)) FOR [LastGeneratedTransactionID]
GO
ALTER TABLE [dbo].[FCProjectCalcProcess]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcProcess_FCProjectCalcStep] FOREIGN KEY([CurrentStepID])
REFERENCES [dbo].[FCProjectCalcStep] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcProcess] CHECK CONSTRAINT [FK_FCProjectCalcProcess_FCProjectCalcStep]
GO
ALTER TABLE [dbo].[FCProjectCalcProcess]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcProcess_UserSecurityGroup_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProjectCalcProcess] CHECK CONSTRAINT [FK_FCProjectCalcProcess_UserSecurityGroup_CreatedBy]
GO
ALTER TABLE [dbo].[FCProjectCalcProcess]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcProcess_UserSecurityGroup_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProjectCalcProcess] CHECK CONSTRAINT [FK_FCProjectCalcProcess_UserSecurityGroup_ModifiedBy]
GO
ALTER TABLE [dbo].[FCProjectCalcProcess]  WITH CHECK ADD  CONSTRAINT [FK_FCProjetCalcProcess_FCProject] FOREIGN KEY([FCProjectID])
REFERENCES [dbo].[FCProject] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcProcess] CHECK CONSTRAINT [FK_FCProjetCalcProcess_FCProject]
GO
ALTER TABLE [dbo].[FCProjectCalcProcess]  WITH CHECK ADD  CONSTRAINT [FK_FCProjetCalcProcess_FCVersion] FOREIGN KEY([FCVersionID])
REFERENCES [dbo].[FCVersion] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcProcess] CHECK CONSTRAINT [FK_FCProjetCalcProcess_FCVersion]
GO
