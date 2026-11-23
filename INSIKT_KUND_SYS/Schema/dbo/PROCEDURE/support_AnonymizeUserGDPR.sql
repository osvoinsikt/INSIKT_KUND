SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[support_AnonymizeUserGDPR]
	@UserID INT
AS

if not exists (select * from UserSecurityGroup where UserID = @UserID) begin
	raiserror ('Failed to run procedure. UserID does not exist in table UserSecurityGroup.', 1, 1)
	return 1
end
if not exists (select * from UserSecurityGroup where UserID = @UserID and IsDeleted = 1) begin
	raiserror ('Failed to run procedure. User is not in state removed in table UserSecurityGroup.', 1, 1)
	return 2
end

begin transaction

	declare @UserNameToAnonymize varchar(255) = (select UserName from UserSecurityGroup where UserID = @UserID)
	declare @FullNameToAnonymize nvarchar(255) = (select FullName from UserSecurityGroup where UserID = @UserID)
	declare @EmailAdressToAnonymize varchar(255) = (select EmailAdress from UserSecurityGroup where UserID = @UserID)
	declare @AnonymizedUserFullName varchar(255) = 'Removed User'

	/* Anonymize the user */
	UPDATE UserSecurityGroup
	SET
		UserName = @UserID,
		DomainID = null,
		SID = '',
		FullName = @AnonymizedUserFullName,
		EmailAdress = null
	WHERE UserID = @UserID

	/* If SuperAdmin is not null anonymize it */
	if exists (select * from UserSecurityGroup where UserID = @UserID and SuperAdmin is not null)
	begin
		update UserSecurityGroup set SuperAdmin = '#AnonymousChicken' where UserID = @UserID
	end

	/* Remove entries from ErrorLog */
	delete from ErrorLog where UserName = @UserNameToAnonymize
	
	/* Remove some connections */
	delete from UserSecurityGroupRelation where UserID = @UserID
	delete from UserSecurityGroupRoleRelation where UserID = @UserID
	delete from UserGroupRelation where UserID = @UserID

	/* Anonymize information in user log */
	update usgl
	set usgl.OldValue = null, usgl.OldDisplayValue = null, usgl.NewValue = null, usgl.NewDisplayValue = null
	from dbo.UserSecurityGroupLog usgl
	where usgl.UserID = @UserID and usgl.TypeID = 5 and PropertyID in (1, 2, 3)

	/* Anonymize email adress in trigger-action */
	update FCProjectCalcTriggerAction set MailRecipient = null where MailRecipient = @EmailAdressToAnonymize

	/* Set UserName to UserID for FCProjectPropertyValue and FCObjectPropertyValue */
	UPDATE FCProjectPropertyValue SET ValueString = @UserID WHERE ValueString = @UserNameToAnonymize
	UPDATE FCObjectPropertyValue SET ValueString = @UserID WHERE ValueString = @UserNameToAnonymize

	/* in ActionLog, replace UserName -> UserID and FullName -> Removed User where we can identify the user to anonymize */
	update FCActionLog set 
		Content =
			cast(
				replace(
					replace(
						cast(Content as nvarchar(max)),
						@UserNameToAnonymize,
						@UserID),
					@FullNameToAnonymize,
					@AnonymizedUserFullName)
				as xml)
	where (VersionID is null and FCProjectID is not null) and
		cast(Content as nvarchar(max)) like '%Value>' + @UserNameToAnonymize + '</%'

	if @@ERROR <> 0 begin
		rollback transaction
		raiserror ('Failed to run procedure support_AnonymizeUserGDPR', 1, 1)
		return 3;
	end

commit transaction

return
GO
