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
