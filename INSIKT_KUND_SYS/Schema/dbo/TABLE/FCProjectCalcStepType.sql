SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectCalcStepType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[ActionName] [nvarchar](150) NOT NULL,
	[StatusName] [nvarchar](150) NOT NULL,
	[ProcessIsWriteEnabled] [bit] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[FinishConfirmText] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_FCProjectCalcStepType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectCalcStepType] ADD  CONSTRAINT [DF_FCProjectCalcStepType_ProcessIsWriteEnabled]  DEFAULT ((0)) FOR [ProcessIsWriteEnabled]
GO
ALTER TABLE [dbo].[FCProjectCalcStepType]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStepType_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcStepType] CHECK CONSTRAINT [FK_FCProjectCalcStepType_CompanyID]
GO
ALTER TABLE [dbo].[FCProjectCalcStepType]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStepType_FCTypeID] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcStepType] CHECK CONSTRAINT [FK_FCProjectCalcStepType_FCTypeID]
GO
