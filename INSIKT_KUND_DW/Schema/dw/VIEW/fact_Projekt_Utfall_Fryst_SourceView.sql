SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dw].[fact_Projekt_Utfall_Fryst_SourceView] as
select 
	[FCProjectID] = f.FCProjectID
    ,[FCVersionID] = v.FCVersionID
	,[ProjektID] = f.ProjektID
	,[MonthID] = f.MonthID
	,[KontoID] = f.KontoID
	,[Amount] = sum(f.Amount)
from dw.fact_Projekt_Utfall_SourceView f
    inner join insikt.FCProject_Versions_CalcProcess v on
        v.FCProjectID = f.FCProjectID
    inner join dw.fact_Projekt_Utilities u on
        u.FCProjectID = f.FCProjectID
        and u.FCVersionID = v.FCVersionID
where
    v.ProcessIsWriteEnabled =  1
	and f.MonthID < u.StartWritabilityMonthID
group by 
	f.FCProjectID
    ,v.FCVersionID
	,f.ProjektID
	,f.MonthID
	,f.KontoID
------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\dw\VIEW\fact_Projekt_Utfall_Fryst_SourceView.sql -----END


GO
