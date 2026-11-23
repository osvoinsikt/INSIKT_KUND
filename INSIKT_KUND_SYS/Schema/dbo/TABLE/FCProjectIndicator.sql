SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectIndicator](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Caption] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[SortOrder] [int] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectIndicator] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectIndicator] ADD  CONSTRAINT [DF_FCProjectIndicator_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCProjectIndicator]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectIndicator_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCProjectIndicator] CHECK CONSTRAINT [FK_FCProjectIndicator_Company]
GO
ALTER TABLE [dbo].[FCProjectIndicator]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectIndicator_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectIndicator] CHECK CONSTRAINT [FK_FCProjectIndicator_FCType]
GO
