SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectUserRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCRoleID] [int] NOT NULL,
	[FCProjectPropertyID] [int] NULL,
	[ValueNumeric] [float] NULL,
	[ValueString] [nvarchar](3000) NULL,
	[FCProjectPropertyPredefinedValueID] [int] NULL,
	[FCProjectID] [int] NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[GroupID] [int] NULL,
	[UserID] [int] NOT NULL,
	[AllProjects] [bit] NULL,
 CONSTRAINT [PK_FCProjectUserRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelation_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCProjectUserRelation] CHECK CONSTRAINT [FK_FCProjectUserRelation_Company]
GO
ALTER TABLE [dbo].[FCProjectUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelation_FCProject] FOREIGN KEY([FCProjectID])
REFERENCES [dbo].[FCProject] ([ID])
GO
ALTER TABLE [dbo].[FCProjectUserRelation] CHECK CONSTRAINT [FK_FCProjectUserRelation_FCProject]
GO
ALTER TABLE [dbo].[FCProjectUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelation_FCProjectProperty] FOREIGN KEY([FCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectUserRelation] CHECK CONSTRAINT [FK_FCProjectUserRelation_FCProjectProperty]
GO
ALTER TABLE [dbo].[FCProjectUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelation_FCProjectPropertyPredefinedValue] FOREIGN KEY([FCProjectPropertyPredefinedValueID])
REFERENCES [dbo].[FCProjectPropertyPredefinedValue] ([ID])
GO
ALTER TABLE [dbo].[FCProjectUserRelation] CHECK CONSTRAINT [FK_FCProjectUserRelation_FCProjectPropertyPredefinedValue]
GO
ALTER TABLE [dbo].[FCProjectUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelation_FCRole] FOREIGN KEY([FCRoleID])
REFERENCES [dbo].[FCRole] ([ID])
GO
ALTER TABLE [dbo].[FCProjectUserRelation] CHECK CONSTRAINT [FK_FCProjectUserRelation_FCRole]
GO
ALTER TABLE [dbo].[FCProjectUserRelation]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectUserRelation_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectUserRelation] CHECK CONSTRAINT [FK_FCProjectUserRelation_FCType]
GO
