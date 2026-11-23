SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConstraintMember](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ConstraintID] [int] NOT NULL,
	[DimensionName] [nvarchar](50) NOT NULL,
	[ElementKey] [nvarchar](100) NULL,
	[UniqueName] [nvarchar](100) NULL,
	[Comment] [nvarchar](max) NULL,
 CONSTRAINT [PK_ConstraintMember] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[ConstraintMember]  WITH CHECK ADD  CONSTRAINT [FK_ConstraintMember_Constraint] FOREIGN KEY([ConstraintID])
REFERENCES [dbo].[Constraint] ([ID])
GO
ALTER TABLE [dbo].[ConstraintMember] CHECK CONSTRAINT [FK_ConstraintMember_Constraint]
GO
