SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCObjectTypeQueryConfig](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCObjectTypeID] [int] NOT NULL,
	[Caption] [nvarchar](55) NOT NULL,
	[Query] [nvarchar](max) NOT NULL,
	[CanExecuteSQL] [nvarchar](max) NULL,
	[SortOrder] [int] NOT NULL,
	[FCObjectQueryTypeID] [int] NOT NULL,
 CONSTRAINT [PK_FCObjectTypeQueryConfig] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCObjectTypeQueryConfig]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectTypeQueryConfig_FCObjectQueryTypeID] FOREIGN KEY([FCObjectQueryTypeID])
REFERENCES [dbo].[FCObjectQueryType] ([ID])
GO
ALTER TABLE [dbo].[FCObjectTypeQueryConfig] CHECK CONSTRAINT [FK_FCObjectTypeQueryConfig_FCObjectQueryTypeID]
GO
ALTER TABLE [dbo].[FCObjectTypeQueryConfig]  WITH CHECK ADD  CONSTRAINT [FK_FCObjectTypeQueryConfig_FCObjectTypeID] FOREIGN KEY([FCObjectTypeID])
REFERENCES [dbo].[FCObjectType] ([ID])
GO
ALTER TABLE [dbo].[FCObjectTypeQueryConfig] CHECK CONSTRAINT [FK_FCObjectTypeQueryConfig_FCObjectTypeID]
GO
