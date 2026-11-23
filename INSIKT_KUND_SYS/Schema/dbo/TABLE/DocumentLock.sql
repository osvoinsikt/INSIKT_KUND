SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentLock](
	[Token] [uniqueidentifier] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[ValidUntil] [datetime] NULL,
 CONSTRAINT [PK_DocumentLock] PRIMARY KEY CLUSTERED 
(
	[Token] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_DocumentLock_DocumentID] UNIQUE NONCLUSTERED 
(
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[DocumentLock]  WITH CHECK ADD  CONSTRAINT [FK_DocumentLock_Document] FOREIGN KEY([DocumentID])
REFERENCES [dbo].[Document] ([ID])
GO
ALTER TABLE [dbo].[DocumentLock] CHECK CONSTRAINT [FK_DocumentLock_Document]
GO
ALTER TABLE [dbo].[DocumentLock]  WITH CHECK ADD  CONSTRAINT [FK_DocumentLock_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[DocumentLock] CHECK CONSTRAINT [FK_DocumentLock_UserSecurityGroup]
GO
