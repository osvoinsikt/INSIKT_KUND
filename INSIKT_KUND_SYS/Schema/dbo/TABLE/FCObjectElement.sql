SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectElement](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ElementKey] [nvarchar](50) NOT NULL,
	[FCObjectID] [int] NOT NULL,
	[ModifiedBy] [int] NOT NULL,
	[ModifiedDate] [smalldatetime] NULL,
	[isDeleted] [bit] NOT NULL,
	[FCVersionID] [int] NULL,
 CONSTRAINT [PK_FCObjectElement] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [ObjectElementUniquePair] UNIQUE NONCLUSTERED 
(
	[ElementKey] ASC,
	[FCObjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCObjectElement] ADD  CONSTRAINT [DF_FCObjectElement_IsDeleted]  DEFAULT ((0)) FOR [isDeleted]
GO
ALTER TABLE [dbo].[FCObjectElement]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectElement_FCObject] FOREIGN KEY([FCObjectID])
REFERENCES [dbo].[FCObject] ([ID])
GO
ALTER TABLE [dbo].[FCObjectElement] CHECK CONSTRAINT [FK_FCObjectElement_FCObject]
GO
ALTER TABLE [dbo].[FCObjectElement]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectElement_FCVersion] FOREIGN KEY([FCVersionID])
REFERENCES [dbo].[FCVersion] ([ID])
GO
ALTER TABLE [dbo].[FCObjectElement] CHECK CONSTRAINT [FK_FCObjectElement_FCVersion]
GO
ALTER TABLE [dbo].[FCObjectElement]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectElement_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCObjectElement] CHECK CONSTRAINT [FK_FCObjectElement_ModifiedBy]
GO
