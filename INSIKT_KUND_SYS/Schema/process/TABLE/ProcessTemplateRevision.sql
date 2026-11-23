SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [process].[ProcessTemplateRevision](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessTemplateID] [int] NOT NULL,
	[RevisionNr] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDraft] [bit] NOT NULL,
	[PublishedDate] [datetime] NULL,
	[PublishedBy] [int] NULL,
	[ChangeLog] [nvarchar](max) NULL,
	[FailedPublish] [bit] NULL,
 CONSTRAINT [PK_ProcessTemplateRevision] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [process].[ProcessTemplateRevision] ADD  CONSTRAINT [DF_ProcessTemplateRevision_IsDraft]  DEFAULT ((0)) FOR [IsDraft]
GO
ALTER TABLE [process].[ProcessTemplateRevision]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTemplateRevision_ProcessTemplate] FOREIGN KEY([ProcessTemplateID])
REFERENCES [process].[ProcessTemplate] ([ID])
GO
ALTER TABLE [process].[ProcessTemplateRevision] CHECK CONSTRAINT [FK_ProcessTemplateRevision_ProcessTemplate]
GO
