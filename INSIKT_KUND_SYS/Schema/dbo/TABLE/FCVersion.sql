SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCVersion](
	[ID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](100) NULL,
	[FiscalYear] [int] NOT NULL,
	[IsBudget] [bit] NULL,
	[IsActiveBudget] [bit] NOT NULL,
	[IsActivePrognos] [bit] NOT NULL,
	[PreviousBudgetID] [int] NULL,
	[PreviousPrognosID] [int] NULL,
	[PrevPreviousBudgetID] [int] NULL,
	[PreviousYear] [int] NULL,
	[PrevPreviousYear] [int] NULL,
	[Month] [int] NULL,
	[PeriodMonth] [int] NULL,
	[CompanyCode] [int] NULL,
	[Type] [int] NOT NULL,
	[IDWithinType] [varchar](2) NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [smalldatetime] NULL,
	[Attribute1] [varchar](50) NULL,
	[Attribute2] [varchar](50) NULL,
	[Attribute3] [varchar](50) NULL,
	[NrOfLockedPeriods] [int] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [smalldatetime] NULL,
	[FCVersionCategoryID] [int] NULL,
	[SortOrder] [int] NULL,
	[IsDeleted] [bit] NOT NULL,
	[OpenForSuperUsers] [bit] NULL,
	[OnlyAvailableToSuperUsers] [bit] NULL,
	[OriginVersionID] [int] NULL,
 CONSTRAINT [PK_FCVersion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FCVersion] ADD  CONSTRAINT [DF_FCVersion_IsActiveBudget]  DEFAULT ((0)) FOR [IsActiveBudget]
GO
ALTER TABLE [dbo].[FCVersion] ADD  CONSTRAINT [DF_FCVersion_IsActivePrognos]  DEFAULT ((0)) FOR [IsActivePrognos]
GO
ALTER TABLE [dbo].[FCVersion] ADD  CONSTRAINT [DF_FCVersion_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCVersion]  WITH CHECK ADD  CONSTRAINT [FK_FCVersion_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCVersion] CHECK CONSTRAINT [FK_FCVersion_CreatedBy]
GO
ALTER TABLE [dbo].[FCVersion]  WITH CHECK ADD  CONSTRAINT [FK_FCVersion_FCVersionCategory] FOREIGN KEY([FCVersionCategoryID])
REFERENCES [dbo].[FCVersionCategory] ([ID])
GO
ALTER TABLE [dbo].[FCVersion] CHECK CONSTRAINT [FK_FCVersion_FCVersionCategory]
GO
ALTER TABLE [dbo].[FCVersion]  WITH CHECK ADD  CONSTRAINT [FK_FCVersion_FCVersionType] FOREIGN KEY([Type])
REFERENCES [dbo].[FCVersionType] ([ID])
GO
ALTER TABLE [dbo].[FCVersion] CHECK CONSTRAINT [FK_FCVersion_FCVersionType]
GO
ALTER TABLE [dbo].[FCVersion]  WITH CHECK ADD  CONSTRAINT [FK_FCVersion_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCVersion] CHECK CONSTRAINT [FK_FCVersion_ModifiedBy]
GO
