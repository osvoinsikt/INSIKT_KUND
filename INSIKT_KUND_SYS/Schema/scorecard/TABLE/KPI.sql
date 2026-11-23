SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[KPI](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ValueTypeID] [int] NOT NULL,
	[TargetFrequency] [int] NOT NULL,
	[TargetIsShared] [bit] NOT NULL,
	[TargetIsReadOnly] [bit] NOT NULL,
	[TargetResponsibleUserID] [int] NULL,
	[ActualFrequency] [int] NOT NULL,
	[ActualIsShared] [bit] NOT NULL,
	[ActualIsReadOnly] [bit] NOT NULL,
	[ActualResponsibleUserID] [int] NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
	[TargetResponsibleRoleID] [int] NULL,
	[ActualResponsibleRoleID] [int] NULL,
	[IsRestricted] [bit] NOT NULL,
 CONSTRAINT [PK_Scorecard_KPI] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [scorecard].[KPI] ADD  CONSTRAINT [DF_Scorecard_KPI_ValueType]  DEFAULT ((1)) FOR [ValueTypeID]
GO
ALTER TABLE [scorecard].[KPI] ADD  CONSTRAINT [DF_Scorecard_KPI_TargetFrequency]  DEFAULT ((1)) FOR [TargetFrequency]
GO
ALTER TABLE [scorecard].[KPI] ADD  CONSTRAINT [DF_Scorecard_KPI_TargetIsShared]  DEFAULT ((0)) FOR [TargetIsShared]
GO
ALTER TABLE [scorecard].[KPI] ADD  CONSTRAINT [DF_Scorecard_KPI_TargetIsReadOnly]  DEFAULT ((0)) FOR [TargetIsReadOnly]
GO
ALTER TABLE [scorecard].[KPI] ADD  CONSTRAINT [DF_Scorecard_KPI_ActualFrequency]  DEFAULT ((1)) FOR [ActualFrequency]
GO
ALTER TABLE [scorecard].[KPI] ADD  CONSTRAINT [DF_Scorecard_KPI_ActualIsShared]  DEFAULT ((0)) FOR [ActualIsShared]
GO
ALTER TABLE [scorecard].[KPI] ADD  CONSTRAINT [DF_Scorecard_KPI_ActualIsReadOnly]  DEFAULT ((0)) FOR [ActualIsReadOnly]
GO
ALTER TABLE [scorecard].[KPI] ADD  CONSTRAINT [DF_Scorecard_KPI_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [scorecard].[KPI] ADD  CONSTRAINT [DF_ScorecardKPI_IsRestricted]  DEFAULT ((0)) FOR [IsRestricted]
GO
ALTER TABLE [scorecard].[KPI]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPI_ActualFrequency] FOREIGN KEY([ActualFrequency])
REFERENCES [scorecard].[FrequencyType] ([ID])
GO
ALTER TABLE [scorecard].[KPI] CHECK CONSTRAINT [FK_Scorecard_KPI_ActualFrequency]
GO
ALTER TABLE [scorecard].[KPI]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPI_ActualResponsibleRole] FOREIGN KEY([ActualResponsibleRoleID])
REFERENCES [scorecard].[OrganisationRole] ([ID])
GO
ALTER TABLE [scorecard].[KPI] CHECK CONSTRAINT [FK_Scorecard_KPI_ActualResponsibleRole]
GO
ALTER TABLE [scorecard].[KPI]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPI_ActualResponsibleUser] FOREIGN KEY([ActualResponsibleUserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[KPI] CHECK CONSTRAINT [FK_Scorecard_KPI_ActualResponsibleUser]
GO
ALTER TABLE [scorecard].[KPI]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPI_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[KPI] CHECK CONSTRAINT [FK_Scorecard_KPI_CreatedBy]
GO
ALTER TABLE [scorecard].[KPI]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPI_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[KPI] CHECK CONSTRAINT [FK_Scorecard_KPI_ModifiedBy]
GO
ALTER TABLE [scorecard].[KPI]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPI_TargetFrequency] FOREIGN KEY([TargetFrequency])
REFERENCES [scorecard].[FrequencyType] ([ID])
GO
ALTER TABLE [scorecard].[KPI] CHECK CONSTRAINT [FK_Scorecard_KPI_TargetFrequency]
GO
ALTER TABLE [scorecard].[KPI]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPI_TargetResponsibleRole] FOREIGN KEY([TargetResponsibleRoleID])
REFERENCES [scorecard].[OrganisationRole] ([ID])
GO
ALTER TABLE [scorecard].[KPI] CHECK CONSTRAINT [FK_Scorecard_KPI_TargetResponsibleRole]
GO
ALTER TABLE [scorecard].[KPI]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPI_TargetResponsibleUser] FOREIGN KEY([TargetResponsibleUserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [scorecard].[KPI] CHECK CONSTRAINT [FK_Scorecard_KPI_TargetResponsibleUser]
GO
ALTER TABLE [scorecard].[KPI]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_KPI_ValueType] FOREIGN KEY([ValueTypeID])
REFERENCES [scorecard].[KPIValueType] ([ID])
GO
ALTER TABLE [scorecard].[KPI] CHECK CONSTRAINT [FK_Scorecard_KPI_ValueType]
GO
