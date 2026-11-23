SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CellComment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NULL,
	[FCTypeID] [int] NULL,
	[ReportID] [int] NULL,
	[CellCommentTypeID] [int] NULL,
 CONSTRAINT [PF_CellComment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_CellComment_FCTypeCompany] ON [dbo].[CellComment]
(
	[FCTypeID] ASC,
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CellComment] ADD  CONSTRAINT [DF_CellComment_CompanyID]  DEFAULT ((1)) FOR [CompanyID]
GO
ALTER TABLE [dbo].[CellComment]  WITH CHECK ADD  CONSTRAINT [FK_CellComment_CellCommentType] FOREIGN KEY([CellCommentTypeID])
REFERENCES [dbo].[CellCommentType] ([ID])
GO
ALTER TABLE [dbo].[CellComment] CHECK CONSTRAINT [FK_CellComment_CellCommentType]
GO
ALTER TABLE [dbo].[CellComment]  WITH CHECK ADD  CONSTRAINT [FK_CellComment_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[CellComment] CHECK CONSTRAINT [FK_CellComment_Company]
GO
ALTER TABLE [dbo].[CellComment]  WITH CHECK ADD  CONSTRAINT [FK_CellComment_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[CellComment] CHECK CONSTRAINT [FK_CellComment_FCType]
GO
ALTER TABLE [dbo].[CellComment]  WITH CHECK ADD  CONSTRAINT [FK_CellComment_Report] FOREIGN KEY([ReportID])
REFERENCES [dbo].[Report] ([ID])
GO
ALTER TABLE [dbo].[CellComment] CHECK CONSTRAINT [FK_CellComment_Report]
GO
