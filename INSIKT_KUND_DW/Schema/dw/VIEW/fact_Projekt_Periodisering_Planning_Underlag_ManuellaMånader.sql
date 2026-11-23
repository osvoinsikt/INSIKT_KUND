SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[fact_Projekt_Periodisering_Planning_Underlag_ManuellaMånader] as
    select
        [FCProjectID] = f.FCProjectID
        ,[FCVersionID] = f.FCVersionID
        ,[MonthID] = f.MonthID
        -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
        ,[KontoID] = f.KontoID
        ,[PeriodiseratBelopp] = sum(f.PeriodiseratBelopp)
        ,[NrOfIncUpdateRows] = sum(f.NrOfIncUpdateRows)
        ,[ManuellMånad] = 1
    from dw.fact_Projekt_Periodisering_Planning_Sum f
        inner join dw.fact_Projekt_Utilities u on 
            u.FCProjectID = f.FCProjectID
            and u.FCVersionID = f.FCVersionID 
    where
        abs(f.PeriodiseratBelopp) > 0.00001
        and f.MonthID >= u.StartWritabilityMonthID
        and f.MonthID <= u.EndMonthID
    group by
        f.FCProjectID
        ,f.FCVersionID
        ,f.MonthID
        -- FLER KODDELAR: Om periodisering ska ske pÃ¥ fler koddelar läggs de till här
        ,f.KontoID


------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\dw\VIEW\fact_Projekt_Periodisering_Planning_Underlag_ManuellaMånader.sql -----END


GO
