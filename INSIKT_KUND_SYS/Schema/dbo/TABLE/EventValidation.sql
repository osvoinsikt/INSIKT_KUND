SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventValidation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EventName] [nvarchar](50) NOT NULL,
	[SQLQuery] [nvarchar](3000) NOT NULL,
	[FCTypeID] [int] NULL,
	[FCObjectTypeID] [int] NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_EventValidation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[EventValidation]  WITH CHECK ADD  CONSTRAINT [FK_EventValidation_FCObjectType] FOREIGN KEY([FCObjectTypeID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[EventValidation] CHECK CONSTRAINT [FK_EventValidation_FCObjectType]
GO
ALTER TABLE [dbo].[EventValidation]  WITH CHECK ADD  CONSTRAINT [FK_EventValidation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[EventValidation] CHECK CONSTRAINT [FK_EventValidation_FCType]
GO
