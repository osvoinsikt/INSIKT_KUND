SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

create view [dw].[fact_Resultat_Planning_Analysis] as
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
	,[BudgetAmount] = CASE WHEN pv.[Type] = 1 and pv.IsActiveBudget = 1 THEN
					f.[PlanningAmount]
				ELSE null END
	,[PrognosAmount] = CASE WHEN pv.[Type] = 2 and pv.IsActiveBudget = 1 THEN
					f.[PlanningAmount]
				ELSE null END
	,[BudgetQuantity] = CASE WHEN pv.[Type] = 1 and pv.IsActiveBudget = 1 THEN
					f.[PlanningQuantity]
				ELSE null END
	,[PrognosQuantity] = CASE WHEN pv.[Type] = 2 and pv.IsActiveBudget = 1 THEN
					f.[PlanningQuantity]
				ELSE null END
from
	[dw].[fact_Resultat_Planning] f
		inner join dw.dim_PlanningVersion pv on
			pv.PlanningVersionID = f.PlanningVersionID
GO
