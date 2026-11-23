SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view scorecard.ActionLogSummary
as
select
	a.ID,
	a.ParentActionLogID,
	a.UserID,
	usg.UserName,
	a.EventDate,
	m.ID OrganisationMemberID,
	m.Name OrganisationMemberName,
	v.ID VersionID,
	v.Name VersionName,
	g.ID GoalID,
	g.Name GoalName,
	act.ID ActivityID,
	act.Name ActivityName,
	kpi.ID KPIID,
	kpi.Name KPIName,
	p.Name Property,
	a.PeriodID,
	a.OldNumericValue, a.OldStringValue, a.OldDisplayValue,
	a.NewNumericValue, a.NewStringValue, a.NewDisplayValue
from scorecard.ActionLog a
	left join scorecard.ActionLogType t on t.ID = a.ActionLogTypeID
	left join scorecard.ActionLogProperty p on p.ID = a.ActionLogPropertyID
	left join scorecard.OrganisationMember m on m.ID = a.OrganisationMemberID
	left join scorecard.Version v on v.ID = a.VersionID
	left join scorecard.Goal g on g.ID = a.GoalID
	left join scorecard.Activity act on act.ID = a.ActivityID
	left join scorecard.KPI kpi on kpi.ID = a.KPIID
	left join UserSecurityGroup usg on usg.UserID = a.UserID
GO
