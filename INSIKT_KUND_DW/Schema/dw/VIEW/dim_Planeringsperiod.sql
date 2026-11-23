SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Spegling av dw.dim_Time men endast dag 1
create view dw.dim_Planeringsperiod as 
select
    [FiscalPeriodID] = t.FiscalPeriodID
    ,[Year] = t.Year
    ,[DateID] = t.DateID
    ,[MonthID] = t.MonthID
    ,[FiscalPeriodName] = t.FiscalPeriodName
    ,[MonthNameWithYear]= t.MonthNameWithYear
    ,[FiscalYear] = t.FiscalYear
    ,[FiscalPeriod]= t.FiscalPeriod
    ,[FiscalDateID]= t.FiscalDateID
    ,[MonthName] = t.MonthName
    ,[MonthShortName]= t.MonthShortName
    ,[MonthShortNameWithYear] = t.MonthShortNameWithYear
from dw.dim_Time t
where
    t.Day = 1

GO
