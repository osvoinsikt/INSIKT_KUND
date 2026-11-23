SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSecurityGroupImport](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TimeStamp] [datetime] NOT NULL,
	[ImportedBy] [int] NOT NULL,
 CONSTRAINT [PK_UserSecurityGroupImport] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserSecurityGroupImport]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurityGroupImport_UserSecurityGroup] FOREIGN KEY([ImportedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[UserSecurityGroupImport] CHECK CONSTRAINT [FK_UserSecurityGroupImport_UserSecurityGroup]
GO
