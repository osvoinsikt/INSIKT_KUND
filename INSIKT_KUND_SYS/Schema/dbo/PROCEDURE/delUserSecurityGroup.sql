SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[delUserSecurityGroup]
(
	@UserID int,
	@CalledByUserID int = -1
)
as

declare @IsUser bit

select @IsUser = (UserTypeID & 1)
from UserSecurityGroup
where UserID = @UserID

-- Security group
if @IsUser = 0
begin
	begin tran
	
	-- Log removed group
	insert into dbo.UserSecurityGroupLog (InitiatedBy, EventDate, TypeID, UserID)
		values (@CalledByUserID, GETUTCDATE(), 7, @UserID)

	create table #usersToUpdateDefaultGroup
	(
		UserID int not null,
		OldDefaultSecurityGroupID int,
		NewDefaultSecurityGroupID int
	)

	-- Get all users whom default group is to be updated
	insert into #usersToUpdateDefaultGroup
	select u.UserID, u.DefaultSecGroupID as OldDefaultSecurityGroupID, min(gr.SecurityGroupID) as NewDefaultSecurityGroupID
	from UserSecurityGroup u
	left join UserSecurityGroupRelation gr on gr.UserID = u.UserID and gr.SecurityGroupID <> @UserID
		left join UserSecurityGroup grg on grg.UserID = gr.SecurityGroupID and grg.IsDeleted = 0
	where u.DefaultSecGroupID = @UserID
	group by u.UserID, u.DefaultSecGroupID

	-- Assign a new default security group for the group users
	update usr
	set DefaultSecGroupID = defGrp.NewDefaultSecurityGroupID
	from UserSecurityGroup usr
		inner join #usersToUpdateDefaultGroup defGrp on defGrp.UserID = usr.UserID

	-- Log updated default group
	insert into dbo.UserSecurityGroupLog (InitiatedBy, EventDate, TypeID, UserID, 
		PropertyID, OldValue, OldDisplayValue, NewValue, NewDisplayValue)
	select @CalledByUserID, GETUTCDATE(), 5, usr.UserID, 8, 
		defGrp.OldDefaultSecurityGroupID, oldDefGrp.FullName,
		defGrp.NewDefaultSecurityGroupID, newDefGrp.FullName
	from UserSecurityGroup usr
		inner join #usersToUpdateDefaultGroup defGrp on defGrp.UserID = usr.UserID
		inner join UserSecurityGroup oldDefGrp on oldDefGrp.UserID = defGrp.OldDefaultSecurityGroupID
		left join UserSecurityGroup newDefGrp on newDefGrp.UserID = defGrp.NewDefaultSecurityGroupID
	order by usr.FullName

	-- Log about removal of relations even though only relations for domain entities are removed
	insert into dbo.UserSecurityGroupLog (InitiatedBy, EventDate, TypeID, UserID, RelatedSecurityGroupID)
	select @CalledByUserID, GETUTCDATE(), 4, usgRel.UserID, usgRel.SecurityGroupID
	from dbo.UserSecurityGroupRelation usgRel
		inner join dbo.UserSecurityGroup usg on usg.UserID = usgRel.UserID
	where usgRel.SecurityGroupID = @UserID
	order by usg.FullName

	-- Apply the following for a domain group
	if exists (select 1 from UserSecurityGroup u where u.UserID = @UserID and u.DomainID is not null and u.UserTypeID = 64)
	begin
		-- Get users that had the group to be removed as the only one
		select usr.UserID
		into #UsersToBeRemoved
		from UserSecurityGroup usr
			inner join UserSecurityGroupRelation gr on gr.SecurityGroupID = @UserID and gr.UserID = usr.UserID
		where usr.UserTypeID in (5, 7) and usr.DomainID is not null and usr.DefaultSecGroupID is null and IsDeleted = 0

		-- Remove relations as relation information can become outdated
		delete from dbo.UserSecurityGroupRelation where SecurityGroupID = @UserID

		-- Mark users as removed
		update usr
		set IsDeleted = 1
		from UserSecurityGroup usr
			inner join #UsersToBeRemoved userToBeRemoved on userToBeRemoved.UserID = usr.UserID

		-- Log removed users
		insert into dbo.UserSecurityGroupLog (InitiatedBy, EventDate, TypeID, UserID)
		select @CalledByUserID, GETUTCDATE(), 2, usr.UserID
		from UserSecurityGroup usr
			inner join #UsersToBeRemoved userToBeRemoved on userToBeRemoved.UserID = usr.UserID
		order by usr.FullName

		delete pv
		from UserSecurityGroupPropertyValue pv
			inner join #UsersToBeRemoved userToBeRemoved on userToBeRemoved.UserID = pv.UserID

		drop table #UsersToBeRemoved
	end

	-- Mark group as removed
	update UserSecurityGroup
	set IsDeleted = 1
	where UserID = @UserID

	drop table #usersToUpdateDefaultGroup

	commit tran
end
-- User
else if @IsUser = 1
begin
	begin tran

	-- Log about removal of relations even though only relations for domain entities are removed
	insert into dbo.UserSecurityGroupLog (InitiatedBy, EventDate, TypeID, UserID, RelatedSecurityGroupID)
	select @CalledByUserID, GETUTCDATE(), 4, usgRel.UserID, usgRel.SecurityGroupID
	from dbo.UserSecurityGroupRelation usgRel
		inner join dbo.UserSecurityGroup usg on usg.UserID = usgRel.SecurityGroupID
	where usgRel.UserID = @UserID
	order by usg.FullName

	if exists (select 1 from UserSecurityGroup u where u.UserID = @UserID and u.DomainID is not null and u.UserTypeID = 3)
	begin
		-- Remove relations for a domain user. Might be a synced user that had the user type changed to ManualUser.
		delete from dbo.UserSecurityGroupRelation where UserID = @UserID
	end

	-- Mark user as removed
	update UserSecurityGroup
	set IsDeleted = 1
	where UserID = @UserID

	-- Log removed user
	insert into dbo.UserSecurityGroupLog (InitiatedBy, EventDate, TypeID, UserID)
		values (@CalledByUserID, GETUTCDATE(), 2, @UserID)

	delete from UserSecurityGroupPropertyValue
	where UserID = @UserID

	commit tran
end  
else  
	raiserror('Unable to find user', 16, 1)
GO
