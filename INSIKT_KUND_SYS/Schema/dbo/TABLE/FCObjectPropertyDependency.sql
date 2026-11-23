SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectPropertyDependency](
	[MasterPropertyID] [int] NOT NULL,
	[DependentPropertyID] [int] NOT NULL,
 CONSTRAINT [PK_FCObjectPropertyDependency] PRIMARY KEY CLUSTERED 
(
	[MasterPropertyID] ASC,
	[DependentPropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCObjectPropertyDependency]  WITH CHECK ADD  CONSTRAINT [Dependent] FOREIGN KEY([DependentPropertyID])
REFERENCES [dbo].[FCObjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCObjectPropertyDependency] CHECK CONSTRAINT [Dependent]
GO
ALTER TABLE [dbo].[FCObjectPropertyDependency]  WITH CHECK ADD  CONSTRAINT [Master] FOREIGN KEY([MasterPropertyID])
REFERENCES [dbo].[FCObjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCObjectPropertyDependency] CHECK CONSTRAINT [Master]
GO
