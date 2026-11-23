SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [integrationInternal].KPI
as
select
	KPIKey = settings.ExternalKey
	,Name = Name
	,Description = Description
	,ValueType = ValueTypeID
	,ActualFrequency = ActualFrequency
	,TargetFrequency = TargetFrequency
	,ActualIsShared = ActualIsShared
	,TargetIsShared = TargetIsShared
	,IsActualValueInputIntegrationEnabled = settings.IsActualValueInputIntegrationEnabled
	,IsTargetValueInputIntegrationEnabled = settings.IsTargetValueInputIntegrationEnabled
	,Enabled = settings.Enabled & ~IsDeleted
from scorecard.KPI kpi
inner join scorecard.KPIIntegrationSettings settings
	on kpi.ID = settings.KPIID

GO
