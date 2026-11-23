SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [process].[ProcessComment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcessInstanceID] [int] NOT NULL,
	[ProcessInstanceActivityID] [int] NOT NULL,
	[Comment] [nvarchar](max) NOT NULL,
	[Created] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[Modified] [datetime] NULL,
	[ModifiedBy] [int] NULL,
 CONSTRAINT [PK_ProcessComment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [process].[ProcessComment]  WITH CHECK ADD  CONSTRAINT [FK_ProcessComment_ProcessInstance] FOREIGN KEY([ProcessInstanceID])
REFERENCES [process].[ProcessInstance] ([ID])
GO
ALTER TABLE [process].[ProcessComment] CHECK CONSTRAINT [FK_ProcessComment_ProcessInstance]
GO
ALTER TABLE [process].[ProcessComment]  WITH CHECK ADD  CONSTRAINT [FK_ProcessComment_ProcessInstanceActivity] FOREIGN KEY([ProcessInstanceActivityID])
REFERENCES [process].[ProcessInstanceActivity] ([ID])
GO
ALTER TABLE [process].[ProcessComment] CHECK CONSTRAINT [FK_ProcessComment_ProcessInstanceActivity]
GO
