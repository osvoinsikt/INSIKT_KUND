SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [scorecard].[OrganisationRole](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_Scorecard_OrganisationRole] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [scorecard].[OrganisationRole_TriggerInsertUpdateDelete]
ON [scorecard].[OrganisationRole]
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	set nocount on

	raiserror ('You cannot modify the Scorecard roles. The builtin roles have fixed functions, and custom roles are not supported. You can however disable the trigger scorecard.OrganisationRole_TriggerInsertUpdateDelete temporarily if you are sure of what you are doing.', 16, 1)
	rollback tran
END
GO
ALTER TABLE [scorecard].[OrganisationRole] ENABLE TRIGGER [OrganisationRole_TriggerInsertUpdateDelete]
GO
