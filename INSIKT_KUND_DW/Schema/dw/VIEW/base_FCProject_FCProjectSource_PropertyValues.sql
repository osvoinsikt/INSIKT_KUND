SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dw].[base_FCProject_FCProjectSource_PropertyValues] as
select
    [FCProjectID] = ppv.ProjectID
    ,[Startdatum_3] = max(case when ppv.ProjectPropertyID = 3 then cast(ppv.ValueString as Date) end) 
    ,[Slutdatum_4] = max(case when ppv.ProjectPropertyID = 4 then cast(ppv.ValueString as Date) end) 
    ,[Projektstatus_5] = max(case when ppv.ProjectPropertyID = 5 then ppv.FCProjectPropertyPredefinedValueID end) 
    ,[Projekttyp_6] = max(case when ppv.ProjectPropertyID = 6 then ppv.FCProjectPropertyPredefinedValueID end) 
    ,[Projektledare_7] = max(case when ppv.ProjectPropertyID = 7 then cast(ppv.ValueNumeric as int) end) 
    ,[SA_Projekt_8] = max(case when ppv.ProjectPropertyID = 8 then ppv.ValueNumeric end) 
    ,[Projektfas_9] = max(case when ppv.ProjectPropertyID = 9 then ppv.ValueNumeric end)
from INSIKT_KUND_SYS.dbo.FCProjectPropertyValue ppv
group by
    ppv.ProjectID

GO
