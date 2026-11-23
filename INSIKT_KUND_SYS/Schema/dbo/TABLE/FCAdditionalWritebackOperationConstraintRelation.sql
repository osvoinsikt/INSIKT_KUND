SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCAdditionalWritebackOperationConstraintRelation](
	[FCAdditionalWritebackOperationID] [int] NOT NULL,
	[ConstraintID] [int] NOT NULL,
 CONSTRAINT [PK_FCAddWritebackOpConstraintRelation] PRIMARY KEY CLUSTERED 
(
	[FCAdditionalWritebackOperationID] ASC,
	[ConstraintID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCAdditionalWritebackOperationConstraintRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCAddWritebackOpConstraint_Constraint] FOREIGN KEY([ConstraintID])
REFERENCES [dbo].[Constraint] ([ID])
GO
ALTER TABLE [dbo].[FCAdditionalWritebackOperationConstraintRelation] CHECK CONSTRAINT [FK_FCAddWritebackOpConstraint_Constraint]
GO
ALTER TABLE [dbo].[FCAdditionalWritebackOperationConstraintRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCAddWritebackOpConstraint_FCAddWritebackOp] FOREIGN KEY([FCAdditionalWritebackOperationID])
REFERENCES [dbo].[FCAdditionalWritebackOperation] ([ID])
GO
ALTER TABLE [dbo].[FCAdditionalWritebackOperationConstraintRelation] CHECK CONSTRAINT [FK_FCAddWritebackOpConstraint_FCAddWritebackOp]
GO
