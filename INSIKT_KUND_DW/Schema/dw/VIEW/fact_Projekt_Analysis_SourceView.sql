SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[fact_Projekt_Analysis_SourceView] as
with source_fact as (
select
    [FCProjectID] = f.FCProjectID
    ,[DateID] = f.MonthID * 100 + 1
    ,[KontoID] = f.KontoID
    ,[AktuellKalkyl] = iif(calcprocess.FCVersionOrder = 1, f.PeriodiseratBelopp, null)
    ,[PrevKalkyl] = iif(calcprocess.FCVersionOrder = 2, f.PeriodiseratBelopp, null)
    ,[Förkalkyl] = iif(calcprocess.FCVersionCategoryID = 1000 and calcprocess.FCVersionCategoryOrder = 1, f.PeriodiseratBelopp, cast(null as decimal(28,8)))
    ,[Budget] = iif(calcprocess.FCVersionCategoryID = 2000 and calcprocess.FCVersionCategoryOrder = 1, f.PeriodiseratBelopp, cast(null as decimal(28,8)))
    ,[Prognos] = iif(calcprocess.FCVersionCategoryID = 3000 and calcprocess.FCVersionCategoryOrder = 1, f.PeriodiseratBelopp, cast(null as decimal(28,8)))
    ,[PrevPrognos] = iif(calcprocess.FCVersionCategoryID = 3000 and calcprocess.FCVersionCategoryOrder = 2, f.PeriodiseratBelopp, cast(null as decimal(28,8)))
from
    [dw].[fact_Projekt_Periodisering_Planning_Sum] f
    inner join dw.base_FCProject p on
        p.FCProjectID = f.FCProjectID
    inner join insikt.FCProject_Versions_CalcProcess calcprocess on
        calcprocess.FCProjectID = f.FCProjectID
        and calcprocess.FCVersionID = f.FCVersionID
where
    isnull(p.IsDeleted, 0) = 0
union all
select
    [FCProjectID] = f.FCProjectID
    ,[DateID] = f.MonthID * 100 + 1
    ,[KontoID] = f.KontoID
    ,[AktuellKalkyl] = iif(calcprocess.FCVersionOrder = 1, f.BeräknatPeriodiseratBelopp, null)
    ,[PrevKalkyl] = iif(calcprocess.FCVersionOrder = 2, f.BeräknatPeriodiseratBelopp, null)
    ,[Förkalkyl] = iif(calcprocess.FCVersionCategoryID = 1000, f.BeräknatPeriodiseratBelopp, cast(null as decimal(28,8)))
    ,[Budget] = iif(calcprocess.FCVersionCategoryID = 2000, f.BeräknatPeriodiseratBelopp, cast(null as decimal(28,8)))
    ,[Prognos] = iif(calcprocess.FCVersionCategoryID = 3000 and calcprocess.FCVersionCategoryOrder = 1, f.BeräknatPeriodiseratBelopp, cast(null as decimal(28,8)))
    ,[PrevPrognos] = iif(calcprocess.FCVersionCategoryID = 3000 and calcprocess.FCVersionCategoryOrder = 2, f.BeräknatPeriodiseratBelopp, cast(null as decimal(28,8)))
from
    dw.fact_Projekt_Periodisering_Planning_Calc f
    inner join dw.base_FCProject p on 
        p.FCProjectID = f.FCProjectID
    inner join insikt.FCProject_Versions_CalcProcess calcprocess on
        calcprocess.FCProjectID = f.FCProjectID
        and calcprocess.FCVersionID = f.FCVersionID
where
    isnull(p.IsDeleted, 0) = 0
union all
select
    [FCProjectID] = f.FCProjectID
    ,[DateID] = f.MonthID * 100 + 1
    ,[KontoID] = f.KontoID
    ,[AktuellKalkyl] = iif(calcprocess.FCVersionOrder = 1, f.Amount, null)
    ,[PrevKalkyl] = iif(calcprocess.FCVersionOrder = 2, f.Amount, null)
    ,[Förkalkyl] = iif(calcprocess.FCVersionCategoryID = 1000, f.Amount, cast(null as decimal(28,8)))
    ,[Budget] = iif(calcprocess.FCVersionCategoryID = 2000, f.Amount, cast(null as decimal(28,8)))
    ,[Prognos] = iif(calcprocess.FCVersionCategoryID = 3000 and calcprocess.FCVersionCategoryOrder = 1, f.Amount, cast(null as decimal(28,8)))
    ,[PrevPrognos] = iif(calcprocess.FCVersionCategoryID = 3000 and calcprocess.FCVersionCategoryOrder = 2, f.Amount, cast(null as decimal(28,8)))
from
    dw.fact_Projekt_Utfall_Fryst f
    inner join dw.base_FCProject p on
        p.FCProjectID = f.FCProjectID
    inner join dw.fact_Projekt_Utilities u on
        u.FCProjectID = f.FCProjectID
        and u.FCVersionID = f.FCVersionID
    inner join insikt.FCProject_Versions_CalcProcess calcprocess on
        calcprocess.FCProjectID = f.FCProjectID
        and calcprocess.FCVersionID = f.FCVersionID
where
    isnull(p.IsDeleted, 0) = 0
)
select
    [FCProjectID] = f.FCProjectID
    ,[DateID] = f.DateID 
    ,[KontoID] = f.KontoID
    ,[AktuellKalkyl] = sum(f.AktuellKalkyl)
    ,[PrevKalkyl] = sum(f.PrevKalkyl)
    ,[Förkalkyl] = sum(f.Förkalkyl)
    ,[Budget] = sum(f.Budget)
    ,[Prognos] = sum(f.Prognos)
    ,[PrevPrognos] = sum(f.PrevPrognos)
from
    source_fact f
group by
    f.FCProjectID
    ,f.DateID
    ,f.KontoID
------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\dw\VIEW\fact_Projekt_Analysis_SourceView.sql -----END


GO
