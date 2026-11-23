SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TriggerInsertUpdate_CustomRoleRestrictions]
    ON [dbo].[Role]
	FOR INSERT, UPDATE
    AS
    BEGIN
    SET NOCOUNT ON
		DECLARE @id int;
		DECLARE @isSystemRole int;
		SELECT @id = ID, @isSystemRole = IsSystemRole From inserted
		IF @id < 1001
		BEGIN
			raiserror ('If you want to insert or update a Role the ID must be over 1000. This is a safety measure to avoid collisions with future System Roles that might be added when upgrading INSIKT. You can however disable the trigger [TriggerInsertUpdate_CustomRoleRestrictions] temporarily if you are sure of what you are doing.',16,1)
			Rollback TRAN
		END
		ELSE IF @isSystemRole <> 0
		BEGIN
			raiserror ('A System Role can not be updated or inserted, you must define it as a Custom Role (ie., [isSystemRole]=0). You can however disable the trigger [TriggerInsertUpdate_CustomRoleRestrictions] temporarily if you are sure of what you are doing.',16,1)
			Rollback TRAN
		END
    END
GO
ALTER TABLE [dbo].[Role] ENABLE TRIGGER [TriggerInsertUpdate_CustomRoleRestrictions]
GO
