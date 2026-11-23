SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomExportRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustomExportID] [int] NOT NULL,
	[FCTypeID] [int] NULL,
	[FCObjectTypeID] [int] NULL,
	[FCDashboardID] [int] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_CustomExportRelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[CustomExportRelation] ADD  CONSTRAINT [DF_CustomExportRelation_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[CustomExportRelation]  WITH CHECK ADD  CONSTRAINT [FK_CustomExportRelation_CustomExportID] FOREIGN KEY([CustomExportID])
REFERENCES [dbo].[CustomExport] ([ID])
GO
ALTER TABLE [dbo].[CustomExportRelation] CHECK CONSTRAINT [FK_CustomExportRelation_CustomExportID]
GO
