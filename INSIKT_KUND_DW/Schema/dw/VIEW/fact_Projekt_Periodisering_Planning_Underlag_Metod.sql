SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[fact_Projekt_Periodisering_Planning_Underlag_Metod] as
select
    [FCProjectID] = null
    ,[FCVersionID] = null
    -- FLER KODDELAR: Om periodisering ska ske på fler koddelar läggs de till här
    ,[KontoID] = null
    ,[PeriodiseringsMetod] = cast(null  as varchar(50))-- 'Platt'|'Manuell'
    ,[StartMonthID] = null
    ,[EndMonthID] = null
    ,[NrOfIncUpdateRows] = cast(null as int)
------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\dw\VIEW\fact_Projekt_Periodisering_Planning_Underlag_Metod.sql -----END


GO
