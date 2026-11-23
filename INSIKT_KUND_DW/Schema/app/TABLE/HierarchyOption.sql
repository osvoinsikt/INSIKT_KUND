SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[HierarchyOption](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[HierarchyID] [int] NOT NULL,
	[HierarchyOptionTypeID] [char](4) NOT NULL,
	[ValueInt] [int] NULL,
	[ValueStr] [nvarchar](500) NULL,
 CONSTRAINT [PK_app_HierarchyOption] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [app].[HierarchyOption]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyOption_app_Hierarchy] FOREIGN KEY([HierarchyID])
REFERENCES [app].[Hierarchy] ([HierarchyID])
GO
ALTER TABLE [app].[HierarchyOption] CHECK CONSTRAINT [FK_app_HierarchyOption_app_Hierarchy]
GO
ALTER TABLE [app].[HierarchyOption]  WITH CHECK ADD  CONSTRAINT [FK_app_HierarchyOption_app_HierarchyOption_Typ] FOREIGN KEY([HierarchyOptionTypeID])
REFERENCES [app].[HierarchyOptionType] ([HierarchyOptionTypeID])
GO
ALTER TABLE [app].[HierarchyOption] CHECK CONSTRAINT [FK_app_HierarchyOption_app_HierarchyOption_Typ]
GO
