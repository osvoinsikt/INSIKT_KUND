SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InputConfiguration](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ConstraintID] [int] NULL,
	[FCTypeID] [int] NOT NULL,
	[InputTypeID] [int] NOT NULL,
	[MultipleChoiceGroupID] [int] NULL,
	[MinValue] [float] NULL,
	[MaxValue] [float] NULL,
	[PersistInCube] [bit] NOT NULL,
	[Priority] [int] NULL,
 CONSTRAINT [PK_InputConfiguration] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[InputConfiguration] ADD  CONSTRAINT [DF_InputConfiguration_PersistInCube]  DEFAULT ((0)) FOR [PersistInCube]
GO
ALTER TABLE [dbo].[InputConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_InputConfiguration_Constraint] FOREIGN KEY([ConstraintID])
REFERENCES [dbo].[Constraint] ([ID])
GO
ALTER TABLE [dbo].[InputConfiguration] CHECK CONSTRAINT [FK_InputConfiguration_Constraint]
GO
ALTER TABLE [dbo].[InputConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_InputConfiguration_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[InputConfiguration] CHECK CONSTRAINT [FK_InputConfiguration_FCType]
GO
ALTER TABLE [dbo].[InputConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_InputConfiguration_InputType] FOREIGN KEY([InputTypeID])
REFERENCES [dbo].[InputType] ([ID])
GO
ALTER TABLE [dbo].[InputConfiguration] CHECK CONSTRAINT [FK_InputConfiguration_InputType]
GO
ALTER TABLE [dbo].[InputConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_InputConfiguration_MultipleChoiceGroup] FOREIGN KEY([MultipleChoiceGroupID])
REFERENCES [dbo].[MultipleChoiceGroup] ([ID])
GO
ALTER TABLE [dbo].[InputConfiguration] CHECK CONSTRAINT [FK_InputConfiguration_MultipleChoiceGroup]
GO
