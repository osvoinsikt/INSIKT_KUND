SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view dw.fact_Projekt_Periodisering_Planning_Underlag_Utfall as
with facttable as
(
    select
        [FCProjectID] = f.FCProjectID
        ,[FCVersionID] = f.FCVersionID
        ,[MonthID] = f.MonthID
        -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
        ,[KontoID] = f.KontoID
        ,[Amount] = f.Amount
    from dw.fact_Projekt_Utfall_Fryst f
)
select
    [FCProjectID] = f.FCProjectID
    ,[FCVersionID] = f.FCVersionID
    ,[MonthID] = max(max(f.monthID)) over(partition by f.FCProjectID)-- Månad efter senaste utfallsmånaden
    -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
    ,[KontoID] = f.KontoID
    ,[Amount] = sum(f.Amount)
from facttable f
group by
    f.FCProjectID
    ,f.FCVersionID
    ,f.KontoID
    -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här


------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\dw\VIEW\fact_Projekt_Periodisering_Planning_Underlag_Utfall.sql -----END


GO
