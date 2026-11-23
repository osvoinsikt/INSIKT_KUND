SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view dw.fact_Projekt_Planning_Analysis as
select
    [ID] = f.ID
    ,[FCProjectID] = f.FCProjectID
    ,[FCVersionID] = f.FCVersionID
    ,[KontoID] = f.KontoID
    ,[Kalkyl] = f.Kalkyl
    /*
    --
    -- För att kunna processa analys i ett separat event kan vi använda en separat IncUpdate-kolumn
    --
    ,[IncUpdate] = f.IncupdateAnalysis
    */
from dw.fact_Projekt_Planning f
    inner join insikt.FCProject_Versions v on
        f.FCProjectID = v.FCProjectID

GO
