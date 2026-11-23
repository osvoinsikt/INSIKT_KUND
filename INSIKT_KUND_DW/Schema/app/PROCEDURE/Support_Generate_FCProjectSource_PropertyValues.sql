SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [app].[Support_Generate_FCProjectSource_PropertyValues]
(
    @INSIKT_SYS nvarchar(max) -- SYS-databas där FCProject finns
)
as
begin try
declare @sql nvarchar(max)
set @sql =  '
declare @inner_sql nvarchar(max)
        ,@columns nvarchar(max)
;with PredefinedValueProperties as (
select distinct
    isPredefinedProperty = 1
    ,FCProjectPropertyID = p.FCProjectPropertyID 
from
    ' + quotename(@INSIKT_SYS) + '.dbo.FCProjectPropertyPredefinedValue p
)
select 
    @columns = string_agg(
        convert(nvarchar(max), concat(quotename(ColumnName), N'' = max(case when ppv.ProjectPropertyID = '', ColumnList.ProjectPropertyID, N'' then '', 
                    case 
                        when ColumnList.isPredefinedProperty = 1 then ''ppv.FCProjectPropertyPredefinedValueID'' 
                        when ColumnList.isDate = 1 then ''cast(ppv.ValueString as Date)''
                        when ColumnList.isUser = 1 then ''cast(ppv.ValueNumeric as int)''
                        when ColumnList.DataType = ''string'' then ''ppv.ValueString''
                        when ColumnList.DataType = ''numeric'' then ''ppv.ValueNumeric''
                        when ColumnList.DataType = ''bit'' then ''cast(ppv.ValueNumeric as bit)''
                        -- vi har endast 3 datatyper definierade, men för att ta höjd så hanterar vi nya typer som ValueNumeric
                        else ''ppv.ValueString''
                    end
                ,'' end) ''
                , nchar(13),nchar(10)))
        , ''    ,''
    ) within group (order by SortOrder)
from (
    select distinct
        ColumnName = concat(property.Name, ''_'', property.ID)
        ,ProjectPropertyID = property.ID
        ,DataType = property.DataType
        ,SortOrder = property.ID
        ,isPredefinedProperty = isnull(predefined.isPredefinedProperty, 0)
        ,isDate = iif(property.ControlID = 5, 1, 0) -- 5 = Date picker
        ,isUser = property.isUser
        ,isProjectCode = property.isProjectCode
        ,isProjectName = property.isProjectName
    from ' + quotename(@INSIKT_SYS) + '.dbo.FCProjectProperty property 
        left join PredefinedValueProperties predefined on predefined.FCProjectPropertyID = property.ID
    where
        property.ID not in (99999)
        and property.isProjectCode = 0
        and property.isProjectName = 0
        and property.isMultiselect = 0
        and property.IsDeleted = 0
) ColumnList

set @inner_sql = ''
create or alter view dw.base_FCProject_FCProjectSource_PropertyValues as
select
    FCProjectID = ppv.ProjectID
    ,'' + @columns + ''
from
    ' + quotename(@INSIKT_SYS) + '.dbo.FCProjectPropertyValue ppv
group by
    ppv.ProjectID
''
exec app.PrintMax @inner_sql
'
exec (@sql)

end try
begin catch
    throw;
end catch

------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\app\PROCEDURE\Support_Generate_FCProjectSource_PropertyValues.sql -----END


GO
