SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UserEffectiveRoles] AS
	with usersAndGroups as (
		select UserID, UserID as RoleRelationID
		from dbo.UserSecurityGroup
		where --usrA.UserID = @userID and
			UserTypeID in (3, 7) and IsDeleted = 0
		union all
		select usrA.UserID, grpRel.SecurityGroupID as RoleRelationID
		from dbo.UserSecurityGroup AS usrA
			inner join dbo.UserSecurityGroupRelation AS grpRel ON
				grpRel.UserID = usrA.UserID
			inner join dbo.UserSecurityGroup grp ON
				grp.UserID = grpRel.SecurityGroupID and grp.IsDeleted = 0
		where usrA.UserTypeID = 5 and usrA.IsDeleted = 0
			--and usrA.UserID = @userID
	), roles as (
		select usersAndGroups.UserID, RoleID
		from usersAndGroups
			inner join UserSecurityGroupRoleRelation roleRel
				on usersAndGroups.RoleRelationID = roleRel.UserID
	)
	select u.UserID, u.UserName,
		case when max(case when RoleID = 7 then 1 else 0 end) = 1 then 1 else 0 end as AdminUser,
		case when max(case when RoleID = 20 then 1 else 0 end) = 1 then 1 else 0 end as AnalysisUser,
		case when max(case when RoleID = 21 then 1 else 0 end) = 1 then 1 else 0 end as AnalysisManager,
		case when max(case when RoleID = 22 then 1 else 0 end) = 1 then 1 else 0 end as AnalysisPrivileged,
		case when max(case when RoleID = 12 then 1 else 0 end) = 1 then 1 else 0 end as BudgetUser,
		case when max(case when RoleID = 13 then 1 else 0 end) = 1 then 1 else 0 end as BudgetPrivileged,
		case when max(case when RoleID = 1 then 1 else 0 end) = 1 then 1 else 0 end as ProjectUser,
		case when max(case when RoleID = 2 then 1 else 0 end) = 1 then 1 else 0 end as ProjectManager
	from [UserSecurityGroup] u
		inner join roles on u.UserID = roles.UserID
	group by u.UserID, u.UserName
GO
