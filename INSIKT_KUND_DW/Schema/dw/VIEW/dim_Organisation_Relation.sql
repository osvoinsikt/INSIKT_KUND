SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dw].[dim_Organisation_Relation] as
select distinct
		[AvdelningID]
from
	dw.fact_GeneralLedger
union select
		[AvdelningID]
from
	dw.dim_Organisation_AdditionalRelation
union select
			[AvdelningID]
from
	dw.fact_Resultat_Planning
GO
