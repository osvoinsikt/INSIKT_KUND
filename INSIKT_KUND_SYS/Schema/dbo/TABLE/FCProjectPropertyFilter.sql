SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCProjectPropertyFilter](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Caption] [varchar](50) NULL,
	[Description] [varchar](500) NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [smalldatetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [smalldatetime] NULL,
	[IsAvailableInProjectList] [bit] NOT NULL,
	[FCTypeID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
 CONSTRAINT [PK_FCProjectPropertyFilter] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Anger om filtret ska vara valbart för användaren i projektlistan' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCProjectPropertyFilter', @level2type=N'COLUMN',@level2name=N'IsAvailableInProjectList'
GO
