SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WebDavDocument](
	[WebDavGUID] [uniqueidentifier] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
 CONSTRAINT [PK_WebDavDocument] PRIMARY KEY CLUSTERED 
(
	[WebDavGUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[WebDavDocument]  WITH CHECK ADD  CONSTRAINT [FK_WebDavDocument_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[WebDavDocument] CHECK CONSTRAINT [FK_WebDavDocument_UserSecurityGroup]
GO
