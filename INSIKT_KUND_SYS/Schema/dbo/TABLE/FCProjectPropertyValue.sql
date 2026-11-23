SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectPropertyValue](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProjectID] [int] NOT NULL,
	[ProjectPropertyID] [int] NOT NULL,
	[ValueNumeric] [float] NULL,
	[ValueString] [nvarchar](max) NULL,
	[FCProjectPropertyPredefinedValueID] [int] NULL,
	[ProjectPropertyGroupInstanceID] [int] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_FCProjectPropertyValue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_FCProjectPropertyValue_Project_ProjectProperty] ON [dbo].[FCProjectPropertyValue]
(
	[ProjectID] ASC,
	[ProjectPropertyID] ASC
)
INCLUDE([ValueNumeric],[ValueString],[FCProjectPropertyPredefinedValueID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FCProjectPropertyValue]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyValue_FCProject] FOREIGN KEY([ProjectID])
REFERENCES [dbo].[FCProject] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyValue] CHECK CONSTRAINT [FK_FCProjectPropertyValue_FCProject]
GO
ALTER TABLE [dbo].[FCProjectPropertyValue]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyValue_FCProjectProperty] FOREIGN KEY([ProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyValue] CHECK CONSTRAINT [FK_FCProjectPropertyValue_FCProjectProperty]
GO
ALTER TABLE [dbo].[FCProjectPropertyValue]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyValue_FCProjectPropertyGroupInstance] FOREIGN KEY([ProjectPropertyGroupInstanceID])
REFERENCES [dbo].[FCProjectPropertyGroupInstance] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyValue] CHECK CONSTRAINT [FK_FCProjectPropertyValue_FCProjectPropertyGroupInstance]
GO
ALTER TABLE [dbo].[FCProjectPropertyValue]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyValue_FCProjectPropertyPredefinedValue] FOREIGN KEY([FCProjectPropertyPredefinedValueID])
REFERENCES [dbo].[FCProjectPropertyPredefinedValue] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyValue] CHECK CONSTRAINT [FK_FCProjectPropertyValue_FCProjectPropertyPredefinedValue]
GO
ALTER TABLE [dbo].[FCProjectPropertyValue]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectPropertyValue_UserSecurityGroup] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCProjectPropertyValue] CHECK CONSTRAINT [FK_FCProjectPropertyValue_UserSecurityGroup]
GO
