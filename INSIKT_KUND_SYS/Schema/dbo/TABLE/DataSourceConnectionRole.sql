SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSourceConnectionRole](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceConnectionID] [int] NOT NULL,
	[RoleName] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_DataSourceConnectionRole] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[DataSourceConnectionRole]  WITH CHECK ADD  CONSTRAINT [FK_DataSourceConnectionRole_DataSourceConnection] FOREIGN KEY([DataSourceConnectionID])
REFERENCES [dbo].[DataSourceConnection] ([ID])
GO
ALTER TABLE [dbo].[DataSourceConnectionRole] CHECK CONSTRAINT [FK_DataSourceConnectionRole_DataSourceConnection]
GO
