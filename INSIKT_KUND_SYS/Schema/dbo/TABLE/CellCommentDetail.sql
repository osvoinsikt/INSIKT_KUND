SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CellCommentDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CellCommentID] [int] NOT NULL,
	[UnitTypeID] [int] NOT NULL,
	[Code] [nvarchar](256) NULL,
	[Name] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[Value] [decimal](18, 2) NULL,
	[Quantity] [decimal](18, 2) NULL,
	[UnitTypeReadOnly] [bit] NOT NULL,
	[NameReadOnly] [bit] NOT NULL,
	[DescriptionReadOnly] [bit] NOT NULL,
	[ValueReadOnly] [bit] NOT NULL,
	[QuantityReadOnly] [bit] NOT NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
 CONSTRAINT [PK_CellCommentDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_CellCommentDetail_CellCommentID] ON [dbo].[CellCommentDetail]
(
	[CellCommentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CellCommentDetail] ADD  CONSTRAINT [DF_CellCommentDetail_UnitTypeReadOnly]  DEFAULT ((0)) FOR [UnitTypeReadOnly]
GO
ALTER TABLE [dbo].[CellCommentDetail] ADD  CONSTRAINT [DF_CellCommentDetail_NameReadOnly]  DEFAULT ((0)) FOR [NameReadOnly]
GO
ALTER TABLE [dbo].[CellCommentDetail] ADD  CONSTRAINT [DF_CellCommentDetail_DescriptionReadOnly]  DEFAULT ((0)) FOR [DescriptionReadOnly]
GO
ALTER TABLE [dbo].[CellCommentDetail] ADD  CONSTRAINT [DF_CellCommentDetail_ValueReadOnly]  DEFAULT ((0)) FOR [ValueReadOnly]
GO
ALTER TABLE [dbo].[CellCommentDetail] ADD  CONSTRAINT [DF_CellCommentDetail_QuantityReadOnly]  DEFAULT ((0)) FOR [QuantityReadOnly]
GO
ALTER TABLE [dbo].[CellCommentDetail]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentDetail_CellComment] FOREIGN KEY([CellCommentID])
REFERENCES [dbo].[CellComment] ([ID])
GO
ALTER TABLE [dbo].[CellCommentDetail] CHECK CONSTRAINT [FK_CellCommentDetail_CellComment]
GO
ALTER TABLE [dbo].[CellCommentDetail]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentDetail_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[CellCommentDetail] CHECK CONSTRAINT [FK_CellCommentDetail_CreatedBy]
GO
ALTER TABLE [dbo].[CellCommentDetail]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentDetail_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[CellCommentDetail] CHECK CONSTRAINT [FK_CellCommentDetail_ModifiedBy]
GO
ALTER TABLE [dbo].[CellCommentDetail]  WITH CHECK ADD  CONSTRAINT [FK_CellCommentDetail_UnitType] FOREIGN KEY([UnitTypeID])
REFERENCES [dbo].[CellCommentDetailUnitType] ([ID])
GO
ALTER TABLE [dbo].[CellCommentDetail] CHECK CONSTRAINT [FK_CellCommentDetail_UnitType]
GO
