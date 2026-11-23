SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProject](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Notes] [nvarchar](max) NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [smalldatetime] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [smalldatetime] NULL,
	[isDeleted] [bit] NULL,
	[SortOrder] [int] NULL,
	[isLocked] [bit] NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[ParentProjectID] [int] NULL,
 CONSTRAINT [PK_FCProject] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProject]  WITH CHECK ADD  CONSTRAINT [FK_FCProject_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCProject] CHECK CONSTRAINT [FK_FCProject_CompanyID]
GO
ALTER TABLE [dbo].[FCProject]  WITH CHECK ADD  CONSTRAINT [FK_FCProject_FCProject] FOREIGN KEY([ParentProjectID])
REFERENCES [dbo].[FCProject] ([ID])
GO
ALTER TABLE [dbo].[FCProject] CHECK CONSTRAINT [FK_FCProject_FCProject]
GO
ALTER TABLE [dbo].[FCProject]  WITH CHECK ADD  CONSTRAINT [FK_FCProject_FCTypeID] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCProject] CHECK CONSTRAINT [FK_FCProject_FCTypeID]
GO
ALTER TABLE [dbo].[FCProject]  WITH CHECK ADD  CONSTRAINT [FK_FCProject_UserSecurityGroup] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProject] CHECK CONSTRAINT [FK_FCProject_UserSecurityGroup]
GO
ALTER TABLE [dbo].[FCProject]  WITH CHECK ADD  CONSTRAINT [FK_FCProject_UserSecurityGroup1] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProject] CHECK CONSTRAINT [FK_FCProject_UserSecurityGroup1]
GO
