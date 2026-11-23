SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCProjectIndicatorState](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCProjectIndicatorID] [int] NOT NULL,
	[Color] [nvarchar](255) NULL,
	[Caption] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[SortOrder] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_FCProjectIndicatorState] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCProjectIndicatorState]  WITH CHECK ADD  CONSTRAINT [FK_FCProjectIndicatorState_FCProjectIndicator] FOREIGN KEY([FCProjectIndicatorID])
REFERENCES [dbo].[FCProjectIndicator] ([ID])
GO
ALTER TABLE [dbo].[FCProjectIndicatorState] CHECK CONSTRAINT [FK_FCProjectIndicatorState_FCProjectIndicator]
GO
