SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[fact_Projekt_Periodisering_Planning_Underlag_Periodisering] as
with facttable as
(
    select
        [FCProjectID] = f.FCProjectID
        ,[FCVersionID] = f.FCVersionID
        -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
        ,[KontoID] = f.KontoID
        ,[PeriodiseratBelopp] = f.PeriodiseratBelopp
        ,[NrOfIncUpdateRows] = f.NrOfIncUpdateRows
        ,[ManuellMånad] = isnull(m.ManuellMånad, 0)
    from dw.fact_Projekt_Periodisering_Planning_Sum f
        left join dw.fact_Projekt_Periodisering_Planning_Underlag_ManuellaMånader m on
            f.FCProjectID = m.FCProjectID
            and f.FCVersionID = m.FCVersionID
            and f.MonthID = m.MonthID
            -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
            and f.KontoID = m.KontoID
        inner join dw.fact_Projekt_Utilities u on 
            u.FCProjectID = f.FCProjectID
            and u.FCVersionID = f.FCVersionID 
    where
        f.MonthID >= u.StartWritabilityMonthID
        and f.MonthID <= u.EndMonthID
)
select
    [FCProjectID] = f.FCProjectID
    ,[FCVersionID] = f.FCVersionID
    -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
    ,[KontoID] = f.KontoID
    ,[PeriodiseratBelopp] = sum(f.PeriodiseratBelopp)
    ,[NrOfIncUpdateRows] = sum(f.NrOfIncUpdateRows)
    ,[AntalManuellaMånader] = sum(f.ManuellMånad)
from facttable f
group by
    f.FCProjectID
    ,f.FCVersionID
    -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
    ,f.KontoID


------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\dw\VIEW\fact_Projekt_Periodisering_Planning_Underlag_Periodisering.sql -----END


GO
