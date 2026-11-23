SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectPropertyValue](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCObjectID] [int] NOT NULL,
	[FCObjectPropertyID] [int] NOT NULL,
	[ValueNumeric] [float] NULL,
	[ValueString] [nvarchar](3000) NULL,
	[ValueDate] [datetime] NULL,
	[FCObjectPropertyPredefinedValueID] [int] NULL,
	[ModifiedBy] [int] NULL,
	[ModifedDate] [smalldatetime] NULL,
 CONSTRAINT [PK_FCObjectPropertyValue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_FCObjectPropertyValue_FCObjectID_FCObjectPropertyID] ON [dbo].[FCObjectPropertyValue]
(
	[FCObjectID] ASC,
	[FCObjectPropertyID] ASC
)
INCLUDE([ValueNumeric],[ValueString],[ValueDate],[FCObjectPropertyPredefinedValueID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FCObjectPropertyValue_FCObjectPropertyID_FCObjectID] ON [dbo].[FCObjectPropertyValue]
(
	[FCObjectPropertyID] ASC,
	[FCObjectID] ASC
)
INCLUDE([ValueNumeric],[ValueString],[ValueDate],[FCObjectPropertyPredefinedValueID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FCObjectPropertyValue]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectPropertyValue_FCObject] FOREIGN KEY([FCObjectID])
REFERENCES [dbo].[FCObject] ([ID])
GO
ALTER TABLE [dbo].[FCObjectPropertyValue] CHECK CONSTRAINT [FK_FCObjectPropertyValue_FCObject]
GO
ALTER TABLE [dbo].[FCObjectPropertyValue]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectPropertyValue_FCObjectProperty] FOREIGN KEY([FCObjectPropertyID])
REFERENCES [dbo].[FCObjectProperty] ([ID])
GO
ALTER TABLE [dbo].[FCObjectPropertyValue] CHECK CONSTRAINT [FK_FCObjectPropertyValue_FCObjectProperty]
GO
ALTER TABLE [dbo].[FCObjectPropertyValue]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectPropertyValue_FCObjectPropertyPredefinedValue] FOREIGN KEY([FCObjectPropertyPredefinedValueID])
REFERENCES [dbo].[FCObjectPropertyPredefinedValue] ([ID])
GO
ALTER TABLE [dbo].[FCObjectPropertyValue] CHECK CONSTRAINT [FK_FCObjectPropertyValue_FCObjectPropertyPredefinedValue]
GO
ALTER TABLE [dbo].[FCObjectPropertyValue]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectPropertyValue_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCObjectPropertyValue] CHECK CONSTRAINT [FK_FCObjectPropertyValue_ModifiedBy]
GO
