SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[Organisation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[DataSourceDimensionHierarchyID] [int] NULL,
	[AutoSync] [bit] NOT NULL,
	[LastUpdated] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Scorecard_Organisation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [scorecard].[Organisation] ADD  CONSTRAINT [DF_Scorecard_Organisation_AutoSync]  DEFAULT ((1)) FOR [AutoSync]
GO
ALTER TABLE [scorecard].[Organisation] ADD  CONSTRAINT [DF_ScorecardOrganisation_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [scorecard].[Organisation]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_Organisation_DataSourceDimensionHierarchy] FOREIGN KEY([DataSourceDimensionHierarchyID])
REFERENCES [dbo].[DataSourceDimensionHierarchy] ([ID])
GO
ALTER TABLE [scorecard].[Organisation] CHECK CONSTRAINT [FK_Scorecard_Organisation_DataSourceDimensionHierarchy]
GO
