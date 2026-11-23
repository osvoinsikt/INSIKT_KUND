SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[fact_Projekt_Utilities_Analysis] as 
select
	[FCProjectID] = f.FCProjectID
	,[FCVersionID] = f.FCVersionID
	,[PrevFCVersionID] = f.PrevFCVersionID
	,[StartMonthID] = f.StartMonthID
	,[StartWritabilityMonthID] = f.StartWritabilityMonthID
	,[EndMonthID] = f.EndMonthID
	,[LastUtfallMonthID] = f.LastUtfallMonthID
from dw.fact_Projekt_Utilities f
	inner join dw.base_FCProject fcp on 
		fcp.FCProjectID = f.FCProjectID
where 
	isnull(fcp.IsDeleted, 0) = 0

GO
