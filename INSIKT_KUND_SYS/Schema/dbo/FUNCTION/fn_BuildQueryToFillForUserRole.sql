SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_BuildQueryToFillForUserRole]
(
	@RoleID int,
	-- If this is set the qtf will be generated to allow all supplier users selectable if the logged in user (@userID) is a supplier.
	@AllowSuppliersSelectableIfLoggedInUserIsSupplier bit
)
returns nvarchar(max)
as
begin

	declare @sql nvarchar(max) =
'declare @SupplierUsers table (UserID int)

insert into @SupplierUsers (UserID)
select UserID from UserSecurityGroup u where isnull(u.SuperAdmin, '''') <> ''''

insert into @SupplierUsers (UserID)
select rel.UserID
from UserSecurityGroup g
	join UserSecurityGroupRelation rel on rel.SecurityGroupID = g.UserID
where isnull(g.SuperAdmin, '''') <> ''''

declare @SupplierUsersAreSelectable bit = 0
'

if @AllowSuppliersSelectableIfLoggedInUserIsSupplier = 1
	set @sql += '
-- If a supplier user is logged in all supplier users are set to selectable (AllowSelection=1)
declare @IsLoggedInUserSupplier bit = (select top 1 1 from @SupplierUsers where UserID = @userID)
if @IsLoggedInUserSupplier = 1
	set @SupplierUsersAreSelectable = 1
'

set @sql += '
;with usersAndGroups as (
	select UserID, UserID as RoleRelationID
	from dbo.UserSecurityGroup AS usrA
	where
		UserTypeID = 3 or usrA.UserTypeID = 7
	union
	select usrA.UserID, grpRel.SecurityGroupID as RoleRelationID
	from dbo.UserSecurityGroup AS usrA
		inner join dbo.UserSecurityGroupRelation AS grpRel ON
			grpRel.UserID = usrA.UserID
	where usrA.UserTypeID = 5
), roles as (
	select distinct usersAndGroups.UserID, RoleID
	from usersAndGroups
		inner join UserSecurityGroupRoleRelation roleRel
			on usersAndGroups.RoleRelationID = roleRel.UserID and roleRel.RoleID = ' + cast(@RoleID as varchar) + '
)
SELECT
	usg.FullName As VisibleName,
	usg.UserID As ValueNumeric,
	usg.UserName As ValueString,
	NULL As isDefault,
	ROW_NUMBER() OVER(ORDER BY usg.FullName ASC) As SortOrder,
	CASE WHEN -- Bestämmer om användaren ska vara valbar eller inte:
			IsDeleted = 0 and -- Borttagen användare
			rr.RoleID is not null and -- Användare som inte tillhör rollen
			(@SupplierUsersAreSelectable = 1 or not exists (select * from @SupplierUsers sup where sup.UserID = usg.UserID)) -- Leverantörsanvändare
		THEN 1
		ELSE 0
	END AS AllowSelection
FROM UserSecurityGroup usg
	left join roles rr on rr.UserID = usg.UserID
WHERE UserTypeID <> 64 and usg.UserID > 0
ORDER BY usg.FullName'

	return @sql
end
GO
