SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCAdditionalWritebackOperationOverride](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCAdditionalWritebackOperationID] [int] NOT NULL,
	[DimensionName] [nvarchar](100) NOT NULL,
	[MemberUniqueName] [nvarchar](250) NOT NULL,
 CONSTRAINT [PK_FCAddWritebackOpOverride] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[FCAdditionalWritebackOperationOverride]  WITH CHECK ADD  CONSTRAINT [FK_FCAddWritebackOpOverride_FCAddWritebackOp] FOREIGN KEY([FCAdditionalWritebackOperationID])
REFERENCES [dbo].[FCAdditionalWritebackOperation] ([ID])
GO
ALTER TABLE [dbo].[FCAdditionalWritebackOperationOverride] CHECK CONSTRAINT [FK_FCAddWritebackOpOverride_FCAddWritebackOp]
GO
