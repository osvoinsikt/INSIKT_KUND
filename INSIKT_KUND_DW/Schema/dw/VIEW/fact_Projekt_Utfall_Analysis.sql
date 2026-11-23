SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[fact_Projekt_Utfall_Analysis] as 
select
    [FCProjectID] = f.FCProjectID
    ,[ProjektID] = f.ProjektID
    ,[MonthID] = f.MonthID
    ,[KontoID] = f.KontoID
    ,[DateID] = f.MonthID * 100 + 1
    ,[Amount] = f.Amount
from dw.fact_Projekt_Utfall f
    inner join dw.base_FCProject p on 
        p.FCProjectID = f.FCProjectID
where
    isnull(p.IsDeleted, 0) = 0

GO
