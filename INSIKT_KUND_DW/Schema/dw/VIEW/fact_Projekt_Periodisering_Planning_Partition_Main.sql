SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[fact_Projekt_Periodisering_Planning_Partition_Main] as
select
      [ID] = f.ID
      ,[FCProjectID] = f.FCProjectID
      ,[FCVersionID] = f.FCVersionID
      ,[MonthID] = f.MonthID
      ,[KontoID] = f.KontoID
      ,[PeriodiseratBelopp] = f.PeriodiseratBelopp
      ,[FgPeriodiseratBelopp] = f.FgPeriodiseratBelopp
      ,[AuditUser] = f.AuditUser
      ,[AuditTime] = f.AuditTime
      ,[ExistsInWriteTable] = f.ExistsInWriteTable
      ,[IncUpdate] = f.IncUpdate
      ,[RowTypeID] = f.RowTypeID
from dw.fact_Projekt_Periodisering_Planning f
where 
      f.ExistsInWriteTable = 0
      and f.IncUpdate = 0

GO
