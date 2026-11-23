SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectDocument](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCObjectID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[CustomExportID] [int] NULL,
 CONSTRAINT [PK_dbo_FCObjectDocument] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCObjectDocument]  WITH CHECK ADD  CONSTRAINT [FK_dbo_FCObjectDocument_CustomExport] FOREIGN KEY([CustomExportID])
REFERENCES [dbo].[CustomExport] ([ID])
GO
ALTER TABLE [dbo].[FCObjectDocument] CHECK CONSTRAINT [FK_dbo_FCObjectDocument_CustomExport]
GO
ALTER TABLE [dbo].[FCObjectDocument]  WITH CHECK ADD  CONSTRAINT [FK_dbo_FCObjectDocument_DocumentID] FOREIGN KEY([DocumentID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[FCObjectDocument] CHECK CONSTRAINT [FK_dbo_FCObjectDocument_DocumentID]
GO
ALTER TABLE [dbo].[FCObjectDocument]  WITH CHECK ADD  CONSTRAINT [FK_dbo_FCObjectDocument_FCObjectID] FOREIGN KEY([FCObjectID])
REFERENCES [dbo].[FCObject] ([ID])
GO
ALTER TABLE [dbo].[FCObjectDocument] CHECK CONSTRAINT [FK_dbo_FCObjectDocument_FCObjectID]
GO
