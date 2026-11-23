SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectListGrouping](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Caption] [nvarchar](255) NOT NULL,
	[FirstFCProjectPropertyID] [int] NULL,
	[SecondFCProjectPropertyID] [int] NULL,
	[ThirdFCProjectPropertyID] [int] NULL,
	[FourthFCProjectPropertyID] [int] NULL,
	[FifthFCProjectPropertyID] [int] NULL,
	[IsDefault] [bit] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[DefaultFCProjectPropertyFilterID] [int] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectListGrouping] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectListGrouping] ADD  CONSTRAINT [DF_FCProjectListGrouping_IsDefault]  DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[FCProjectListGrouping] ADD  CONSTRAINT [DF_FCProjectListGrouping_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FCProjectListGrouping]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectListGrouping_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCProjectListGrouping] CHECK CONSTRAINT [FK_FCProjectListGrouping_CompanyID]
GO
ALTER TABLE [dbo].[FCProjectListGrouping]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectListGrouping_FCProjectPropertyFilter] FOREIGN KEY([DefaultFCProjectPropertyFilterID])
REFERENCES [dbo].[FCProjectPropertyFilter] ([ID])
GO
ALTER TABLE [dbo].[FCProjectListGrouping] CHECK CONSTRAINT [FK_FCProjectListGrouping_FCProjectPropertyFilter]
GO
ALTER TABLE [dbo].[FCProjectListGrouping]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectListGrouping_FCTypeID] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCProjectListGrouping] CHECK CONSTRAINT [FK_FCProjectListGrouping_FCTypeID]
GO
ALTER TABLE [dbo].[FCProjectListGrouping]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectListGrouping_FifthGroupProperty_FCProjectProperty] FOREIGN KEY([FifthFCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectListGrouping] CHECK CONSTRAINT [FK_FCProjectListGrouping_FifthGroupProperty_FCProjectProperty]
GO
ALTER TABLE [dbo].[FCProjectListGrouping]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectListGrouping_FirstGroupProperty_FCProjectProperty] FOREIGN KEY([FirstFCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectListGrouping] CHECK CONSTRAINT [FK_FCProjectListGrouping_FirstGroupProperty_FCProjectProperty]
GO
ALTER TABLE [dbo].[FCProjectListGrouping]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectListGrouping_FourthGroupProperty_FCProjectProperty] FOREIGN KEY([FourthFCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectListGrouping] CHECK CONSTRAINT [FK_FCProjectListGrouping_FourthGroupProperty_FCProjectProperty]
GO
ALTER TABLE [dbo].[FCProjectListGrouping]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectListGrouping_SecondGroupProperty_FCProjectProperty] FOREIGN KEY([SecondFCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectListGrouping] CHECK CONSTRAINT [FK_FCProjectListGrouping_SecondGroupProperty_FCProjectProperty]
GO
ALTER TABLE [dbo].[FCProjectListGrouping]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectListGrouping_ThirdGroupProperty_FCProjectProperty] FOREIGN KEY([ThirdFCProjectPropertyID])
REFERENCES [dbo].[FCProjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCProjectListGrouping] CHECK CONSTRAINT [FK_FCProjectListGrouping_ThirdGroupProperty_FCProjectProperty]
GO
