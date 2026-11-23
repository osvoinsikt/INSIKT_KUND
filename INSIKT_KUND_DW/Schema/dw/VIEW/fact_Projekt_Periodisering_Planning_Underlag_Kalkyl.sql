SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[fact_Projekt_Periodisering_Planning_Underlag_Kalkyl] as
with facttable as
(
    select
        [FCProjectID] = f.FCProjectID
        ,[FCVersionID] = f.FCVersionID
        ,[Kalkyl] = f.Kalkyl
        -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
        ,[KontoID] = f.KontoID
        ,[NrOfIncUpdateRows] = f.NrOfIncUpdateRows
    from dw.fact_Projekt_Planning_Sum f
)
select
    [FCProjectID] = f.FCProjectID
    ,[FCVersionID] = f.FCVersionID
    -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
    ,[KontoID] = f.KontoID
    ,[Kalkyl] = sum(f.Kalkyl)
    ,[NrOfIncUpdateRows] = sum(f.NrOfIncUpdateRows)
from facttable f
group by
    f.FCProjectID
    ,f.FCVersionID
    ,f.KontoID


------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\dw\VIEW\fact_Projekt_Periodisering_Planning_Underlag_Kalkyl.sql -----END


GO
