SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dw].[dim_PlanningVersion] as
SELECT 
	[PlanningVersionID] = pv.[ID]
	,pv.[Name]
	,pv.[Description]
	,pv.[FiscalYear]
	,pv.[IsBudget]
	,pv.[IsActiveBudget]
	,pv.[IsActivePrognos]
	,pv.[PreviousBudgetID]
	,pv.[PreviousPrognosID]
	,pv.[PrevPreviousBudgetID]
	,pv.[PreviousYear]
	,pv.[PrevPreviousYear]
	,ISNULL(pv.[Month], 0) as [Month]
	,isnull(pv.[PeriodMonth], pv.[FiscalYear] * 100 + 1) as [PeriodMonth]
	,pv.[CompanyCode]
	,pv.[Type]
	,pv.[IDWithinType]
	,pv.[CreatedBy]
	,pv.[CreatedDate]
	,pv.[Attribute1]
	,pv.[Attribute2]
	,pv.[Attribute3]
	,pv.[NrOfLockedPeriods]
	,pv.[ModifiedBy]
	,pv.[ModifiedDate]
	,pv.[FCVersionCategoryID]
	,pv.[SortOrder]
	,ISNULL(pv.[IsDeleted], 0) as IsDeleted
	,[OpenForSuperUsers] = isnull(pv.[OpenForSuperUsers], 0)
	,pv.[OnlyAvailableToSuperUsers]
	,pv.[OriginVersionID]

	,FCVersionType_ID = pvT.ID
	,FCVersionType_Name = pvT.Name

	,[PreviousBudgetToCurrentMonthDiff] = isnull((pv.[FiscalYear] - pvPreviousBudget.FiscalYear) * 12, 0)
	,[PreviousPrognosToCurrentMonthDiff] = isnull((pv.[FiscalYear] - pvPreviousPrognos.FiscalYear) * 12, 0)

	,InsiktTimeToAckPeriodOffset = isnull((pv.FiscalYear - (pv.[PeriodMonth] / 100)) * 12, 0)

FROM 
	[INSIKT_KUND_SYS].dbo.[FCVersion] pv
		inner join [INSIKT_KUND_SYS].dbo.FCVersionFCTypeRelation rel on 
			rel.FCTypeID = 1 and rel.FCVersionID = pv.ID
		left join [INSIKT_KUND_SYS].dbo.FCVersionType pvT on
			pvT.ID = pv.[type]
		left join [INSIKT_KUND_SYS].dbo.[FCVersion] pvPreviousBudget on
			pvPreviousBudget.[ID] = pv.[PreviousBudgetID]
		left join [INSIKT_KUND_SYS].dbo.[FCVersion] pvPreviousPrognos on
			pvPreviousPrognos.[ID] = pv.[PreviousPrognosID]
GO
