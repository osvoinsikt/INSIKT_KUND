SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectComment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCObjectID] [int] NOT NULL,
	[Comment] [nvarchar](max) NOT NULL,
	[Created] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[Modified] [datetime] NULL,
	[ModifiedBy] [int] NULL,
 CONSTRAINT [PK_dbo_FCObjectComment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCObjectComment]  WITH CHECK ADD  CONSTRAINT [FK_dbo_FCObjectComment_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCObjectComment] CHECK CONSTRAINT [FK_dbo_FCObjectComment_CreatedBy]
GO
ALTER TABLE [dbo].[FCObjectComment]  WITH CHECK ADD  CONSTRAINT [FK_dbo_FCObjectComment_FCObjectID] FOREIGN KEY([FCObjectID])
REFERENCES [dbo].[FCObject] ([ID])
GO
ALTER TABLE [dbo].[FCObjectComment] CHECK CONSTRAINT [FK_dbo_FCObjectComment_FCObjectID]
GO
ALTER TABLE [dbo].[FCObjectComment]  WITH CHECK ADD  CONSTRAINT [FK_dbo_FCObjectComment_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCObjectComment] CHECK CONSTRAINT [FK_dbo_FCObjectComment_ModifiedBy]
GO
