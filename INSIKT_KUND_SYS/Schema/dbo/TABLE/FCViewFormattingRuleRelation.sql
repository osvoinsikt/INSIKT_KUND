SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCViewFormattingRuleRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FormattingRuleID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[FCViewID] [int] NULL,
	[CompanyID] [int] NOT NULL,
	[IsSwitchedView] [bit] NOT NULL,
	[SwitchedViewID] [int] NULL,
	[IsTransactionView] [bit] NOT NULL,
 CONSTRAINT [PK_FCViewFormattingRuleRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCViewFormattingRuleRelation] ADD  CONSTRAINT [DF_FCViewFormattingRuleRelation_IsSwitchedView]  DEFAULT ((0)) FOR [IsSwitchedView]
GO
ALTER TABLE [dbo].[FCViewFormattingRuleRelation] ADD  CONSTRAINT [DF_FCViewFormattingRuleRelation_IsTransactionView]  DEFAULT ((0)) FOR [IsTransactionView]
GO
ALTER TABLE [dbo].[FCViewFormattingRuleRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCViewFormattingRuleRelation_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCViewFormattingRuleRelation] CHECK CONSTRAINT [FK_FCViewFormattingRuleRelation_Company]
GO
ALTER TABLE [dbo].[FCViewFormattingRuleRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCViewFormattingRuleRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCViewFormattingRuleRelation] CHECK CONSTRAINT [FK_FCViewFormattingRuleRelation_FCType]
GO
ALTER TABLE [dbo].[FCViewFormattingRuleRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCViewFormattingRuleRelation_FCView] FOREIGN KEY([FCViewID])
REFERENCES [dbo].[FCView] ([ID])
GO
ALTER TABLE [dbo].[FCViewFormattingRuleRelation] CHECK CONSTRAINT [FK_FCViewFormattingRuleRelation_FCView]
GO
ALTER TABLE [dbo].[FCViewFormattingRuleRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCViewFormattingRuleRelation_FormattingRule] FOREIGN KEY([FormattingRuleID])
REFERENCES [dbo].[FormattingRule] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FCViewFormattingRuleRelation] CHECK CONSTRAINT [FK_FCViewFormattingRuleRelation_FormattingRule]
GO
