SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCInstructionDocument](
	[FCInstructionID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
 CONSTRAINT [PK_FCInstructionDocument] PRIMARY KEY CLUSTERED 
(
	[FCInstructionID] ASC,
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCInstructionDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCInstructionDocument_Document] FOREIGN KEY([DocumentID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[FCInstructionDocument] CHECK CONSTRAINT [FK_FCInstructionDocument_Document]
GO
ALTER TABLE [dbo].[FCInstructionDocument]  WITH CHECK ADD  CONSTRAINT [FK_FCInstructionDocument_FCInstruction] FOREIGN KEY([FCInstructionID])
REFERENCES [dbo].[FCInstruction] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FCInstructionDocument] CHECK CONSTRAINT [FK_FCInstructionDocument_FCInstruction]
GO
