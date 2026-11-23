SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectProcessTemplateConstraint](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[ConstraintQuery] [nvarchar](max) NOT NULL,
	[FCTypeID] [int] NOT NULL,
 CONSTRAINT [PK_FCProjectProcessTemplateConstraint] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectProcessTemplateConstraint]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectProcessTemplateConstraint_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectProcessTemplateConstraint] CHECK CONSTRAINT [FK_FCProjectProcessTemplateConstraint_FCType]
GO
