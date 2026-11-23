SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view integrationInternal.MaxVersionStamp as
select
	DatasetName = 'KPIValue_Output'
	,MaxVersionStamp = max(VersionStamp)
from
	integrationInternal.KPIValue_Output
union all
select
	DatasetName = 'KPITargetValue_Output'
	,MaxVersionStamp = max(VersionStamp)
from
	integrationInternal.[KPITargetValue_Output]
GO
