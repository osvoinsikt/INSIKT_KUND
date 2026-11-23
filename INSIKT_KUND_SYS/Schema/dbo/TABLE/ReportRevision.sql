SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReportRevision](
	[ReportID] [int] NOT NULL,
	[RevisionNr] [int] NOT NULL,
	[ReportName] [varchar](200) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [int] NOT NULL,
	[Data] [xml] NOT NULL,
	[DataVersion] [int] NOT NULL,
	[ReportTypeID] [int] NOT NULL,
	[AdvancedTitlePattern] [varchar](200) NULL,
	[AdvancedTitlePresentationObject] [int] NULL,
 CONSTRAINT [PK__ReportRe__5EF6000676EC6E40] PRIMARY KEY CLUSTERED 
(
	[ReportID] ASC,
	[RevisionNr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[ReportRevision]  WITH CHECK ADD  CONSTRAINT [FK__ReportRev__Modif__79C8DAEB] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[ReportRevision] CHECK CONSTRAINT [FK__ReportRev__Modif__79C8DAEB]
GO
ALTER TABLE [dbo].[ReportRevision]  WITH CHECK ADD  CONSTRAINT [FK__ReportRev__Repor__78D4B6B2] FOREIGN KEY([ReportID])
REFERENCES [dbo].[Report] ([ID])
GO
ALTER TABLE [dbo].[ReportRevision] CHECK CONSTRAINT [FK__ReportRev__Repor__78D4B6B2]
GO
ALTER TABLE [dbo].[ReportRevision]  WITH CHECK ADD  CONSTRAINT [FK_ReportRevision_ReportType] FOREIGN KEY([ReportTypeID])
REFERENCES [dbo].[ReportType] ([ID])
GO
ALTER TABLE [dbo].[ReportRevision] CHECK CONSTRAINT [FK_ReportRevision_ReportType]
GO
