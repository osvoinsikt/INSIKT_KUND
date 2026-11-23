SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

create view [dw].[fact_Resultat_Planning_Analysis_Partition_Main] as
select
	[ID] = f.[ID]
	,[PlanningVersionID] = f.[PlanningVersionID]
	,[PostingDateID] = f.[PostingDateID]
	,[Organisation_LeafID] = f.[Organisation_LeafID]
 
	,[AvdelningID] = f.[AvdelningID]
 
	,[KampanjID] = f.[KampanjID]
 
	,[ProjektID] = f.[ProjektID]
 
	,[VarugruppID] = f.[VarugruppID]
 
	,[KontoID] = f.[KontoID]
	,[PlanningAmount] = f.[PlanningAmount]
	,[PlanningQuantity] = f.[PlanningQuantity]
	,[AuditUser] = f.[AuditUser]
	,[AuditTime] = f.[AuditTime]
	,[ExistsInWriteTable] = f.[ExistsInWriteTable]
	,[IncUpdate] = f.[IncUpdate]
	,[RowTypeID] = f.[RowTypeID]
	,f.[BudgetAmount]
	,f.[PrognosAmount]
	,f.[BudgetQuantity]
	,f.[PrognosQuantity]
from
	[dw].[fact_Resultat_Planning_Analysis] f
where
	f.IncUpdate = 0
GO
