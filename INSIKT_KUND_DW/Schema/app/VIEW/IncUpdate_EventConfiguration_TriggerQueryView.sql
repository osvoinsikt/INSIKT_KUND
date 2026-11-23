SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [app].[IncUpdate_EventConfiguration_TriggerQueryView] as
select
    EventID = e.EventID
    ,TriggerQuery =   
            case                          
                when e.EventTriggerTypeID = 'IncUpdate' then
                    N'select ' + ISNULL(e.TriggerIdColumnName, N'ID') + N' from ' + e.TriggerTable + N' where IncUpdate = 1' + ISNULL(N' and (' + e.TriggerTableFilter + N')', N'')
                when e.EventTriggerTypeID = 'RowsExists' then
                    N'select ' + ISNULL(e.TriggerIdColumnName, N'ID') + N' from ' + e.TriggerTable + ISNULL(N' where (' + e.TriggerTableFilter + N')', N'')
                when e.EventTriggerTypeID = 'CustomQuery' then
                    e.CustomTriggerQuery
  
            end
	,TriggerProcedure =   
            case                          
                when e.EventTriggerTypeID = 'CustomProcedure' then
                    e.CustomTriggerQuery
  
            end
	,IsDisabled = e.IsDisabled
from
    [app].IncUpdate_EventConfiguration e
GO
