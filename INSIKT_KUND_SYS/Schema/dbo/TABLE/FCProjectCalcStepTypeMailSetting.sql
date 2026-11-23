SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectCalcStepTypeMailSetting](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectCalcStepTypeID] [int] NOT NULL,
	[MailOnEnter] [bit] NOT NULL,
	[MailOnLeave] [bit] NOT NULL,
	[MailOnProgress] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectCalcStepTypeMailSetting] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeMailSetting] ADD  CONSTRAINT [DF_FCProjectCalcStepTypeMailSetting_MailOnEnter]  DEFAULT ((0)) FOR [MailOnEnter]
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeMailSetting] ADD  CONSTRAINT [DF_FCProjectCalcStepTypeMailSetting_MailOnLeave]  DEFAULT ((0)) FOR [MailOnLeave]
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeMailSetting] ADD  CONSTRAINT [DF_FCProjectCalcStepTypeMailSetting_MailOnProgress]  DEFAULT ((0)) FOR [MailOnProgress]
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeMailSetting]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectCalcStepTypeMailSetting_FCProjectCalcStepType] FOREIGN KEY([FCProjectCalcStepTypeID])
REFERENCES [dbo].[FCProjectCalcStepType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectCalcStepTypeMailSetting] CHECK CONSTRAINT [FK_FCProjectCalcStepTypeMailSetting_FCProjectCalcStepType]
GO
