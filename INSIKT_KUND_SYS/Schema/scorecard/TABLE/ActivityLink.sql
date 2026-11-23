SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[ActivityLink](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MasterActivityID] [int] NOT NULL,
	[DependentActivityID] [int] NOT NULL,
	[Type] [int] NOT NULL,
 CONSTRAINT [PK_Scorecard_ActivityLink] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [scorecard].[ActivityLink]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActivityLink_DependentActivity] FOREIGN KEY([DependentActivityID])
REFERENCES [scorecard].[Activity] ([ID])
GO
ALTER TABLE [scorecard].[ActivityLink] CHECK CONSTRAINT [FK_Scorecard_ActivityLink_DependentActivity]
GO
ALTER TABLE [scorecard].[ActivityLink]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActivityLink_MasterActivity] FOREIGN KEY([MasterActivityID])
REFERENCES [scorecard].[Activity] ([ID])
GO
ALTER TABLE [scorecard].[ActivityLink] CHECK CONSTRAINT [FK_Scorecard_ActivityLink_MasterActivity]
GO
ALTER TABLE [scorecard].[ActivityLink]  WITH CHECK ADD  CONSTRAINT [FK_Scorecard_ActivityLink_Type] FOREIGN KEY([Type])
REFERENCES [scorecard].[ActivityLinkType] ([ID])
GO
ALTER TABLE [scorecard].[ActivityLink] CHECK CONSTRAINT [FK_Scorecard_ActivityLink_Type]
GO
