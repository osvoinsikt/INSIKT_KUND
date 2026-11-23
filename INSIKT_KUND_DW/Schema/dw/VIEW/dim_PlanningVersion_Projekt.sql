SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[dim_PlanningVersion_Projekt] as
select 
    [FCVersionID] = v.ID
    ,[Name] = v.Name
from INSIKT_KUND_SYS.dbo.FCVersion v
where
    v.FCVersionCategoryID in (1000, 2000, 3000)

GO
