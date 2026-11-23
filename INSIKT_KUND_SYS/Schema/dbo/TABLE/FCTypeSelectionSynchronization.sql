SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCTypeSelectionSynchronization](
	[FirstFCTypeID] [int] NOT NULL,
	[SecondFCTypeID] [int] NOT NULL,
	[SynchronizationTypeID] [int] NOT NULL,
 CONSTRAINT [PK_FCTypeSelectionSynchronization] PRIMARY KEY CLUSTERED 
(
	[FirstFCTypeID] ASC,
	[SecondFCTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCTypeSelectionSynchronization]  WITH CHECK ADD  CONSTRAINT [FK_FCTypeSelectionSynchronization_FCType_First] FOREIGN KEY([FirstFCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCTypeSelectionSynchronization] CHECK CONSTRAINT [FK_FCTypeSelectionSynchronization_FCType_First]
GO
ALTER TABLE [dbo].[FCTypeSelectionSynchronization]  WITH CHECK ADD  CONSTRAINT [FK_FCTypeSelectionSynchronization_FCType_Second] FOREIGN KEY([SecondFCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCTypeSelectionSynchronization] CHECK CONSTRAINT [FK_FCTypeSelectionSynchronization_FCType_Second]
GO
ALTER TABLE [dbo].[FCTypeSelectionSynchronization]  WITH CHECK ADD  CONSTRAINT [FK_FCTypeSelectionSynchronization_FCTypeSelectionSynchronizationType] FOREIGN KEY([SynchronizationTypeID])
REFERENCES [dbo].[FCTypeSelectionSynchronizationType] ([ID])
GO
ALTER TABLE [dbo].[FCTypeSelectionSynchronization] CHECK CONSTRAINT [FK_FCTypeSelectionSynchronization_FCTypeSelectionSynchronizationType]
GO
