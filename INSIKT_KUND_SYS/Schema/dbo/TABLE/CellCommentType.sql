SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CellCommentType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[DataSourceID] [int] NOT NULL,
	[TextTemplate] [nvarchar](max) NULL,
	[IsReadOnly] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[AllowAnyoneToEditComment] [bit] NOT NULL,
	[MemberAccessFCTypeID] [int] NULL,
 CONSTRAINT [PK_CellCommentType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[CellCommentType] ADD  DEFAULT ((0)) FOR [IsReadOnly]
GO
ALTER TABLE [dbo].[CellCommentType] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[CellCommentType] ADD  CONSTRAINT [DF_CellCommentType_AllowAnyoneToEditComment]  DEFAULT ((0)) FOR [AllowAnyoneToEditComment]
GO
ALTER TABLE [dbo].[CellCommentType]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentType_DataSources] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DataSources] ([ID])
GO
ALTER TABLE [dbo].[CellCommentType] CHECK CONSTRAINT [FK_CellCommentType_DataSources]
GO
ALTER TABLE [dbo].[CellCommentType]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentType_MemberAccessFCType] FOREIGN KEY([MemberAccessFCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[CellCommentType] CHECK CONSTRAINT [FK_CellCommentType_MemberAccessFCType]
GO
