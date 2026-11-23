SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCProcess](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCVersion] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[FCLevel01] [varchar](20) NOT NULL,
	[FCLevel02] [varchar](20) NULL,
	[FCLevel03] [varchar](20) NULL,
	[FCLevel04] [varchar](20) NULL,
	[FCLevel05] [varchar](20) NULL,
	[CreatedDate] [smalldatetime] NULL,
	[CreatedBy] [int] NOT NULL,
	[ModifiedDate] [smalldatetime] NULL,
	[ModifiedBy] [int] NULL,
	[FinishedDate] [smalldatetime] NULL,
	[FinishedBy] [int] NULL,
	[ApprovedDate] [smalldatetime] NULL,
	[ApprovedBy] [int] NULL,
	[SecondaryApprovedDate] [smalldatetime] NULL,
	[SecondaryApprovedBy] [int] NULL,
	[LastGeneratedTransactionID] [int] NULL,
 CONSTRAINT [PK_FCProcess] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCProcess] ADD  CONSTRAINT [DF_FCProcess_LastGeneratedTransactionID]  DEFAULT ((0)) FOR [LastGeneratedTransactionID]
GO
ALTER TABLE [dbo].[FCProcess]  WITH CHECK ADD  CONSTRAINT [FK_FCProcess_ApprovedBy] FOREIGN KEY([ApprovedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProcess] CHECK CONSTRAINT [FK_FCProcess_ApprovedBy]
GO
ALTER TABLE [dbo].[FCProcess]  WITH CHECK ADD  CONSTRAINT [FK_FCProcess_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCProcess] CHECK CONSTRAINT [FK_FCProcess_Company]
GO
ALTER TABLE [dbo].[FCProcess]  WITH CHECK ADD  CONSTRAINT [FK_FCProcess_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProcess] CHECK CONSTRAINT [FK_FCProcess_CreatedBy]
GO
ALTER TABLE [dbo].[FCProcess]  WITH CHECK ADD  CONSTRAINT [FK_FCProcess_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCProcess] CHECK CONSTRAINT [FK_FCProcess_FCType]
GO
ALTER TABLE [dbo].[FCProcess]  WITH CHECK ADD  CONSTRAINT [FK_FCProcess_FCVersion] FOREIGN KEY([FCVersion])
REFERENCES [dbo].[FCVersion] ([ID])
GO
ALTER TABLE [dbo].[FCProcess] CHECK CONSTRAINT [FK_FCProcess_FCVersion]
GO
ALTER TABLE [dbo].[FCProcess]  WITH CHECK ADD  CONSTRAINT [FK_FCProcess_FinishedBy] FOREIGN KEY([FinishedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProcess] CHECK CONSTRAINT [FK_FCProcess_FinishedBy]
GO
ALTER TABLE [dbo].[FCProcess]  WITH CHECK ADD  CONSTRAINT [FK_FCProcess_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProcess] CHECK CONSTRAINT [FK_FCProcess_ModifiedBy]
GO
ALTER TABLE [dbo].[FCProcess]  WITH CHECK ADD  CONSTRAINT [FK_FCProcess_SecondaryApprovedBy] FOREIGN KEY([SecondaryApprovedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProcess] CHECK CONSTRAINT [FK_FCProcess_SecondaryApprovedBy]
GO
