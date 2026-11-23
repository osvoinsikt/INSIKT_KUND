SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[fact_Projekt_Periodisering_Planning_Calc_Analysis_FactCDC] as
    select
        [CDC_ID] = f.CDC_ID
        ,[FCProjectID] = f.FCProjectID
        ,[FCVersionID] = f.FCVersionID
        ,[MonthID] = f.MonthID
        ,[DateID] = f.MonthID * 100 + 1
        ,[KontoID] = f.KontoID
        ,[PeriodiseratBelopp] = f.BeräknatPeriodiseratBelopp
    from dw.fact_Projekt_Periodisering_Planning_Calc_FactCDC f
        inner join insikt.FCProject_Versions v on
            f.FCProjectID = v.FCProjectID

GO
