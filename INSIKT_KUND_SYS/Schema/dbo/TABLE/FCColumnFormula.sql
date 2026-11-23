SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCColumnFormula](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Caption] [nvarchar](200) NOT NULL,
	[Description] [nvarchar](400) NULL,
	[FCColumnID] [int] NOT NULL,
	[FCColumnFormulaTypeID] [int] NOT NULL,
	[MeasureUniqueName] [nvarchar](100) NOT NULL,
	[InverseMeasureUniqueName] [nvarchar](100) NULL,
	[FilterOnColumnContext] [bit] NOT NULL,
	[UseParameters] [bit] NOT NULL,
 CONSTRAINT [PK_FCColumnFormula] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCColumnFormula] ADD  CONSTRAINT [DF_FCColumnFormula_FilterOnColumnContext]  DEFAULT ((1)) FOR [FilterOnColumnContext]
GO
ALTER TABLE [dbo].[FCColumnFormula] ADD  CONSTRAINT [DF_FCColumnFormula_UseParameters]  DEFAULT ((0)) FOR [UseParameters]
GO
ALTER TABLE [dbo].[FCColumnFormula]  WITH CHECK ADD  CONSTRAINT [FK_FCColumnFormula_FCColumns] FOREIGN KEY([FCColumnID])
REFERENCES [dbo].[FCColumns] ([ID])
GO
ALTER TABLE [dbo].[FCColumnFormula] CHECK CONSTRAINT [FK_FCColumnFormula_FCColumns]
GO
ALTER TABLE [dbo].[FCColumnFormula]  WITH CHECK ADD  CONSTRAINT [FK_FCColumnFormula_FColumnFormulaType] FOREIGN KEY([FCColumnFormulaTypeID])
REFERENCES [dbo].[FCColumnFormulaType] ([ID])
GO
ALTER TABLE [dbo].[FCColumnFormula] CHECK CONSTRAINT [FK_FCColumnFormula_FColumnFormulaType]
GO
