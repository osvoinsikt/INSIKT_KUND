SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[fact_Projekt_Planning_Partition_Main] as
select
    [ID] = f.ID
    ,[FCProjectID] = f.FCProjectID
    ,[FCVersionID] = f.FCVersionID
    ,[KontoID] = f.KontoID
    ,[Kalkyl] = f.Kalkyl
    ,[FgKalkyl] = f.FgKalkyl
    ,[AuditUser] = f.AuditUser
    ,[AuditTime] = f.AuditTime
    ,[ExistsInWriteTable] = f.ExistsInWriteTable
    ,[IncUpdate] = f.IncUpdate
    ,[RowTypeID] = f.RowTypeID
from dw.fact_Projekt_Planning f
where 
    f.ExistsInWriteTable = 0 
    and f.IncUpdate = 0

GO
