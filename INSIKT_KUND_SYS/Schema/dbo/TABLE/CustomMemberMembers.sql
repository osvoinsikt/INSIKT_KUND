SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomMemberMembers](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Caption] [nvarchar](255) NOT NULL,
	[UniqueName] [nvarchar](500) NOT NULL,
	[CustomMemberID] [int] NOT NULL,
 CONSTRAINT [PK_CustomMemberMembers] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[CustomMemberMembers]  WITH CHECK ADD  CONSTRAINT [FK_CustomMemberMembers_CustomMembers] FOREIGN KEY([CustomMemberID])
REFERENCES [dbo].[CustomMembers] ([ID])
GO
ALTER TABLE [dbo].[CustomMemberMembers] CHECK CONSTRAINT [FK_CustomMemberMembers_CustomMembers]
GO
