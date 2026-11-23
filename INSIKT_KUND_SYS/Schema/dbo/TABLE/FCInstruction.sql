SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCInstruction](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[FCVersionID] [int] NULL,
	[TextHTML] [nvarchar](max) NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[Created] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[Modified] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_FCInstruction] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCInstruction] ADD  CONSTRAINT [DF_FCInstruction_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCInstruction]  WITH CHECK ADD  CONSTRAINT [FK_FCInstruction_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCInstruction] CHECK CONSTRAINT [FK_FCInstruction_CreatedBy]
GO
ALTER TABLE [dbo].[FCInstruction]  WITH CHECK ADD  CONSTRAINT [FK_FCInstruction_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCInstruction] CHECK CONSTRAINT [FK_FCInstruction_ModifiedBy]
GO
