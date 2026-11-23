SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProcessComment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessID] [int] NOT NULL,
	[Comment] [nvarchar](max) NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[Created] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[Modified] [datetime] NULL,
 CONSTRAINT [PK_FCProcessComment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProcessComment]  WITH CHECK ADD  CONSTRAINT [FK_FCProcessComment_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProcessComment] CHECK CONSTRAINT [FK_FCProcessComment_CreatedBy]
GO
ALTER TABLE [dbo].[FCProcessComment]  WITH CHECK ADD  CONSTRAINT [FK_FCProcessComment_FCProcess] FOREIGN KEY([ProcessID])
REFERENCES [dbo].[FCProcess] ([ID])
GO
ALTER TABLE [dbo].[FCProcessComment] CHECK CONSTRAINT [FK_FCProcessComment_FCProcess]
GO
ALTER TABLE [dbo].[FCProcessComment]  WITH CHECK ADD  CONSTRAINT [FK_FCProcessComment_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProcessComment] CHECK CONSTRAINT [FK_FCProcessComment_ModifiedBy]
GO
