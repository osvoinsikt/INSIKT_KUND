SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MultipleChoice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MultipleChoiceGroupID] [int] NOT NULL,
	[Caption] [varchar](100) NOT NULL,
	[Color] [char](9) NULL,
	[SubGroupCaption] [nvarchar](255) NULL,
	[Value] [decimal](15, 5) NULL,
 CONSTRAINT [PK_MultipleChoice] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[MultipleChoice]  WITH CHECK ADD  CONSTRAINT [FK_MultipleChoice_MultipleChoiceGroup] FOREIGN KEY([MultipleChoiceGroupID])
REFERENCES [dbo].[MultipleChoiceGroup] ([ID])
GO
ALTER TABLE [dbo].[MultipleChoice] CHECK CONSTRAINT [FK_MultipleChoice_MultipleChoiceGroup]
GO
