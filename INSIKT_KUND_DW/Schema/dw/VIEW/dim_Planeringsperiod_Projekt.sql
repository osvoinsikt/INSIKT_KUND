SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view dw.dim_Planeringsperiod_Projekt as 

-- Används för att bygga dimensionen Planeringsperiod i Projekt. Ska nycklas mot MonthID
-- Vid brutet räkenskapsår använder vi p.FiscalPeriodID som MonthID i dimensionen
-- Name sätts till MonthNameWithYear
-- Type på dimensionen ska vara Time, och attributet MonthID ska vara typen Months
-- Year ska ha attributet Years
-- Hierarki byggs för År - Månad
--
select
    [MonthID] = p.MonthID
    ,[MonthNameWithYear] = p.MonthNameWithYear
    ,[MonthName] = p.MonthName
    ,[MonthShortName] = p.MonthShortName
    ,[MonthShortNameWithYear] = p.MonthShortNameWithYear
    ,[Year] = p.Year
    ,[DateID] = p.DateID
from dw.dim_Planeringsperiod p

GO
