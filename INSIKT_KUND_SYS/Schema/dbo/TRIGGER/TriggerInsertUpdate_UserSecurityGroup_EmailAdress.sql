SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [dbo].[TriggerInsertUpdate_UserSecurityGroup_EmailAdress] on [dbo].[UserSecurityGroup]
after insert, update as
begin
	-- Make sure email address is not null for internal users
	if exists (
		select 1 from inserted ins
		where ins.DomainID is null and ins.UserTypeID in (3, 5, 7) and ins.IsDeleted = 0 and ins.EmailAdress is null
	)
	begin
		raiserror('Email address for an internal user cannot be null.', 16, 1);
		rollback transaction
		return
	end

	-- Make sure email address is unique among all internal users
	if exists (
		select 1
		from UserSecurityGroup usg
			inner join inserted ins on rtrim(ltrim(ins.EmailAdress)) = rtrim(ltrim(usg.EmailAdress))
		where ins.DomainID is null and usg.UserID != ins.UserID and usg.EmailAdress is not null and ins.EmailAdress is not null
			and usg.UserTypeID in (3, 5, 7) and ins.UserTypeID in (3, 5, 7) and usg.IsDeleted = 0 and ins.IsDeleted = 0
	)
	begin
		raiserror('Email address must be unique.', 16, 2);
		rollback transaction
		return
	end
end
GO
ALTER TABLE [dbo].[UserSecurityGroup] ENABLE TRIGGER [TriggerInsertUpdate_UserSecurityGroup_EmailAdress]
GO
