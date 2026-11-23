SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[fact_Projekt_Periodisering_Planning_Analysis] as
select
    [ID] = f.ID
    ,[FCProjectID] = f.FCProjectID
    ,[FCVersionID] = f.FCVersionID
    ,[DateID] = f.MonthID * 100 + 1
    ,[MonthID] = f.MonthID
    ,[KontoID] = f.KontoID
    ,[PeriodiseratBelopp] = f.PeriodiseratBelopp
    /*
    --
    -- För att kunna processa analys i ett separat event kan vi använda en separat IncUpdate-kolumn
    --
    ,[IncUpdate] = f.IncupdateAnalysis
    */
    -- select *
from dw.fact_Projekt_Periodisering_Planning f
    inner join insikt.FCProject_Versions v on
        f.FCProjectID = v.FCProjectID


------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\dw\VIEW\fact_Projekt_Periodisering_Planning_Analysis.sql -----END


GO
