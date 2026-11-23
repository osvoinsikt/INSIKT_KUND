SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\dw\VIEW\fact_Projekt_Utfall_SourceView.sql -----START

CREATE view [dw].[fact_Projekt_Utfall_SourceView] as
select 
	[FCProjectID] = fcp.FCProjectID
	,[ProjektID] = f.ProjektID
	,[MonthID] = t.MonthID
	,[KontoID] = f.KontoID
	,[Amount] = sum(f.Amount)
from dw.fact_GeneralLedger f
	inner join dw.base_FCProject fcp on 
		fcp.ProjektID = f.ProjektID
	inner join dw.dim_Time t on 
		t.DateID = f.PostingDateID
	inner join dw.dim_Konto_Projekt k on
		k.KontoID = f.KontoID
group by 
	fcp.FCProjectID
	,f.ProjektID
	,t.MonthID
	,f.KontoID
	


------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\dw\VIEW\fact_Projekt_Utfall_SourceView.sql -----END


GO
