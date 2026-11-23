SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************
 #Desc: 			Uppdaterar ID för alla kundanpassade roller (ej systemroller) 
					med ID lägre än 1000 att få just ett ID över 1000.
					Detta för att slippa krockar mellan kundanpassade roller och nya systemroller i framtiden.

 #Used By:			-
 #Creator:			Emil Ahlqvist
 #CreateDate:		151021
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE PROCEDURE [dbo].[support_FixIDsOfCustomRoles]
AS
BEGIN

	-- Remove temporary table #temp.
	IF object_id('tempdb.dbo.#temp') is not null
	begin
		 drop table #temp
	end

	DECLARE @NewID int;
	DECLARE @OldID int;
	DECLARE @Name varchar(50);
	DECLARE @Caption varchar(50);
	DECLARE @SystemModuleID int;
	DECLARE @IsModulePrimary int;
	DECLARE @IsSystemRole int;

	-- Disable restrictions trigger on table.
	ALTER TABLE [dbo].Role DISABLE TRIGGER TriggerInsertUpdate_CustomRoleRestrictions

	-- Select all custom roles.
	SELECT * INTO #temp FROM [dbo].Role WHERE IsSystemRole = 0 AND ID < 1000

	WHILE EXISTS(SELECT * FROM #temp)
	Begin
		--Make sure that the new ID does not already exist in the Role table and is > 1000.
		SELECT @NewID = CASE WHEN Max(ID)+1 > 1000 THEN Max(ID)+1
							ELSE 1000
						END
		From Role

		-- Select top 1 row from #temp
		SELECT Top 1 @OldID = ID, @Name = Name, @Caption = Caption, @SystemModuleID = SystemModuleID, @IsModulePrimary = IsModulePrimary, @IsSystemRole = IsSystemRole From #temp

		-- Insert a copy of the role with the new ID.
		INSERT INTO [dbo].Role (ID, Name, Caption, SystemModuleID, IsModulePrimary, IsSystemRole) VALUES (@NewID, @Name, @Caption, @SystemModuleID, @IsModulePrimary, @IsSystemRole)

		-- Update all RoleTaskRelations with the new updated ID.
		UPDATE RoleTaskRelation SET RoleID = @newID WHERE RoleID = @oldID

		-- Update all UserSecurityGroupRelations with the new updated ID.
		UPDATE UserSecurityGroupRoleRelation SET RoleID = @newID WHERE RoleID = @oldID

		DELETE #temp WHERE ID = @OldID

		-- Remove the old Role.
		DELETE Role WHERE ID = @OldID
		
		-- Increment ID.
		SET @NewID = @NewID + 1
	End

	-- Enable restrictions trigger on table.
	ALTER TABLE [dbo].Role ENABLE TRIGGER TriggerInsertUpdate_CustomRoleRestrictions

	drop table #temp
END
GO
