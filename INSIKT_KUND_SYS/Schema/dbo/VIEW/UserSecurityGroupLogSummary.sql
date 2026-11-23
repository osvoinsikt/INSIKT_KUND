SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view dbo.UserSecurityGroupLogSummary as
select 
	l.ID, l.InitiatedBy, l.EventDate, 
	t.[Type], 
	u.FullName as UserSecurityGroupFullName,
	g.FullName as RelatedSecurityGroupFullName,
	r.[Name] as Role, 
	p.PropertyName as Property,
	l.OldValue, l.OldDisplayValue,
	l.NewValue, l.NewDisplayValue
from UserSecurityGroupLog l
	inner join UserSecurityGroupLogType t on l.TypeID = t.ID
	inner join UserSecurityGroup u on l.UserID = u.UserID
	left join UserSecurityGroup g on l.RelatedSecurityGroupID = g.UserID
	left join Role r on l.RoleID = r.ID
	left join UserSecurityGroupLogProperty p on l.PropertyID = p.ID
GO
