SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[fact_Projekt_Utfall_Analysis_FactCDC] as 
select
    [CDC_ID] = f.CDC_ID
    ,[FCProjectID] = f.FCProjectID
    ,[ProjektID] = f.ProjektID
    ,[MonthID] = f.MonthID
    ,[KontoID] = f.KontoID
    ,[DateID] = f.MonthID * 100 + 1
    ,[Amount] = f.Amount
from dw.fact_Projekt_Utfall_FactCDC f

GO
