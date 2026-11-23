SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectPropertyDependency](
	[MasterPropertyID] [int] NOT NULL,
	[DependentPropertyID] [int] NOT NULL,
	[QueryToComputeNewValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_FCProjectPropertyDependency_1] PRIMARY KEY CLUSTERED 
(
	[MasterPropertyID] ASC,
	[DependentPropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectPropertyDependency]  WITH CHECK ADD  CONSTRAINT [DependentRelation] FOREIGN KEY([DependentPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyDependency] CHECK CONSTRAINT [DependentRelation]
GO
ALTER TABLE [dbo].[FCProjectPropertyDependency]  WITH CHECK ADD  CONSTRAINT [MasterRelation] FOREIGN KEY([MasterPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectPropertyDependency] CHECK CONSTRAINT [MasterRelation]
GO
