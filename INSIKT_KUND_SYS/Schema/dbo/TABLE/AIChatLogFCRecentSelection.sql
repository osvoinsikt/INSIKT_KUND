SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AIChatLogFCRecentSelection](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AIChatLogID] [int] NOT NULL,
	[FCRecentSelectionID] [int] NOT NULL,
 CONSTRAINT [PK_AIChatLogFCRecentSelection] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[AIChatLogFCRecentSelection]  WITH CHECK ADD  CONSTRAINT [FK_AIChatLogFCRecentSelection_AIChatLog] FOREIGN KEY([AIChatLogID])
REFERENCES [dbo].[AIChatLog] ([ID])
GO
ALTER TABLE [dbo].[AIChatLogFCRecentSelection] CHECK CONSTRAINT [FK_AIChatLogFCRecentSelection_AIChatLog]
GO
ALTER TABLE [dbo].[AIChatLogFCRecentSelection]  WITH CHECK ADD  CONSTRAINT [FK_AIChatLogFCRecentSelection_FCRecentSelection] FOREIGN KEY([FCRecentSelectionID])
REFERENCES [dbo].[FCRecentSelection] ([ID])
GO
ALTER TABLE [dbo].[AIChatLogFCRecentSelection] CHECK CONSTRAINT [FK_AIChatLogFCRecentSelection_FCRecentSelection]
GO
