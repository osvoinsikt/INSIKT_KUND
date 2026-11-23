SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Report](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](200) NOT NULL,
	[Description] [varchar](1000) NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [smalldatetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [smalldatetime] NULL,
	[CategoryID] [int] NULL,
	[Data] [xml] NOT NULL,
	[isCommon] [bit] NOT NULL,
	[User] [int] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[ReportTypeID] [int] NOT NULL,
	[Restricted] [bit] NULL,
	[Inactive] [bit] NOT NULL,
	[GUID] [varchar](50) NULL,
	[Version] [int] NULL,
	[DisplayModeID] [int] NULL,
	[IsQuickReport] [bit] NOT NULL,
	[LocalInReportID] [int] NULL,
	[HasRevisions] [bit] NOT NULL,
	[HasSnapshots] [bit] NOT NULL,
	[FormattingRuleID] [int] NULL,
	[LinkID] [int] NULL,
	[GridMetadataID] [int] NULL,
	[AdvancedTitlePattern] [nvarchar](255) NULL,
	[AdvancedTitlePresentationObject] [int] NULL,
 CONSTRAINT [PK_Report] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [IX_Report_CategoryID] ON [dbo].[Report]
(
	[CategoryID] ASC,
	[IsQuickReport] ASC,
	[LocalInReportID] ASC,
	[Inactive] ASC
)
INCLUDE([ID],[isCommon],[User]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Report_Quick_Local_Inactive] ON [dbo].[Report]
(
	[IsQuickReport] ASC,
	[LocalInReportID] ASC,
	[Inactive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Report] ADD  CONSTRAINT [DF_Report_ReportTypeID]  DEFAULT ((1)) FOR [ReportTypeID]
GO
ALTER TABLE [dbo].[Report] ADD  CONSTRAINT [DF_Report_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[Report] ADD  CONSTRAINT [DF_Report_DisplayModeID]  DEFAULT ((1)) FOR [DisplayModeID]
GO
ALTER TABLE [dbo].[Report] ADD  CONSTRAINT [DF__Report__IsQuickR__094028A5]  DEFAULT ((0)) FOR [IsQuickReport]
GO
ALTER TABLE [dbo].[Report] ADD  CONSTRAINT [DF_Report_HasRevisions]  DEFAULT ((0)) FOR [HasRevisions]
GO
ALTER TABLE [dbo].[Report] ADD  CONSTRAINT [DF_Report_HasSnapshots]  DEFAULT ((0)) FOR [HasSnapshots]
GO
ALTER TABLE [dbo].[Report]  WITH CHECK ADD  CONSTRAINT [FK_Report_Category] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Category] ([ID])
GO
ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_Report_Category]
GO
ALTER TABLE [dbo].[Report]  WITH CHECK ADD  CONSTRAINT [FK_Report_FormattingRule] FOREIGN KEY([FormattingRuleID])
REFERENCES [dbo].[FormattingRule] ([ID])
GO
ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_Report_FormattingRule]
GO
ALTER TABLE [dbo].[Report]  WITH CHECK ADD  CONSTRAINT [FK_Report_GridMetadata] FOREIGN KEY([GridMetadataID])
REFERENCES [dbo].[GridMetadata] ([ID])
GO
ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_Report_GridMetadata]
GO
ALTER TABLE [dbo].[Report]  WITH CHECK ADD  CONSTRAINT [FK_Report_Link] FOREIGN KEY([LinkID])
REFERENCES [dbo].[Link] ([ID])
GO
ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_Report_Link]
GO
ALTER TABLE [dbo].[Report]  WITH CHECK ADD  CONSTRAINT [FK_Report_Report] FOREIGN KEY([LocalInReportID])
REFERENCES [dbo].[Report] ([ID])
GO
ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_Report_Report]
GO
ALTER TABLE [dbo].[Report]  WITH CHECK ADD  CONSTRAINT [FK_Report_ReportDisplayMode] FOREIGN KEY([DisplayModeID])
REFERENCES [dbo].[ReportDisplayMode] ([ID])
GO
ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_Report_ReportDisplayMode]
GO
ALTER TABLE [dbo].[Report]  WITH CHECK ADD  CONSTRAINT [FK_Report_ReportType] FOREIGN KEY([ReportTypeID])
REFERENCES [dbo].[ReportType] ([ID])
GO
ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_Report_ReportType]
GO
ALTER TABLE [dbo].[Report]  WITH CHECK ADD  CONSTRAINT [FK_Report_User] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_Report_User]
GO
ALTER TABLE [dbo].[Report]  WITH CHECK ADD  CONSTRAINT [FK_Report_User1] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_Report_User1]
GO
ALTER TABLE [dbo].[Report]  WITH CHECK ADD  CONSTRAINT [FK_Report_User2] FOREIGN KEY([User])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_Report_User2]
GO
