SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [app].[IncUpdate_EventConfiguration_ProcessQueryView] as
select
    EventID = e.EventID
    ,p.Name
    ,ProcessQuery =   
            N'
                SELECT
                    *
                FROM
                    ' + nullif(isnull(p.CustomSourceTable, e.TriggerTable), N'') + N' f
                WHERE
                    ' + isnull(e.TriggerIdColumnName, N'ID') + N' in (select ID from [app].IncUpdate_Process_Data where EventID = ' + CAST(p.EventID as nvarchar(max))  + N')'
                    +
                    iif
                    (
                        p.WriteEnabledMeasuregroup = 1
                        ,N'
                    and ExistsInWriteTable = 0'
                        ,N''
  
                    )
                    +
                    isnull
                    ( N'
                    and ('  + nullif(isnull(p.CustomSourceFilter, e.TriggerTableFilter), N'') + N')'
  
                    ,N'')
from
    [app].IncUpdate_EventConfiguration_Process p
            inner join [app].IncUpdate_EventConfiguration e on
                e.EventID = p.EventID
GO
