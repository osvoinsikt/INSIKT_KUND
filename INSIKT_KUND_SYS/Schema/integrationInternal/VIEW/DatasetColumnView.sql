SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [integrationInternal].[DatasetColumnView] as
with ResourceColumn as
(
	select 
		c.object_id
		
		,ColumnName = c.name
		,ColumnOrder = c.column_id
		,DataType = 
			case t.name
				when 'timestamp' then 'binary(8)'
				else
					t.name + 
						case
							when t.name IN ('real','money','decimal','numeric') then
								'(' + convert(varchar(3),coalesce(c.precision,'')) 
								+ ','+ convert(varchar(3),coalesce(ODBCSCALE(c.system_type_id, c.scale),'')) + ')'

							when t.name IN ('char','nvarchar','varchar','nchar') then
								'(' + iif(COLUMNPROPERTY(c.object_id, c.name, 'charmaxlen') = -1, 'max', cast(isnull(COLUMNPROPERTY(c.object_id, c.name, 'charmaxlen'),'') as varchar)) + ')'
							else 
								''
						end
				end
		,Nullable = iif(c.is_nullable = 1, 1, 0)
		,DefaultValue = defConst.definition
		,Mandatory = iif(c.is_nullable = 1 or c.is_identity = 1 or defConst.object_id is not null, 0, 1)
		,Writable = 
			iif
			(
				c.is_identity = 1 
				or c.is_computed = 1
				or c.system_type_id = 189 -- timestamp
				,0
				,1
			)		
		,JsonPath = '$."' + replace(c.name, '"', '\"') + '"'
		,IsTablePrimaryKey = IIF(pkCol.column_id is null, 0, 1)
		,IsVersionStamp = IIF(t.name = 'timestamp', 1, 0)
		
	from 
		sys.columns c
			inner join sys.types t on
				c.user_type_id = t.user_type_id
			left join sys.indexes pk on
				pk.object_id = c.object_id
				and pk.is_primary_key = 1
			left join sys.index_columns pkCol on
				pkCol.object_id = pk.object_id
				and pkCol.index_id = pk.index_id
				and pkCol.column_id = c.column_id
			left join sys.default_constraints defConst on
				defConst.parent_object_id = c.object_id
				and defConst.parent_column_id = c.column_id
)

select
	DatasetName = conf.DatasetName
	,ColumnName = col.ColumnName
	,ColumnOrder = col.ColumnOrder
	,DataType = col.DataType	
	,JsonPath = col.JsonPath
	,IsWritable = iif(col.Writable = 1 and isnull(confStatusCol.IsConfStatusCol, 0) = 0, 1, 0)
	,IsTablePrimaryKey = col.IsTablePrimaryKey
	,IsNullable = col.Nullable
	,IsMandatory = col.Mandatory
	,IsDatasetPrimaryKey =  isnull(iif(conf.LogicalPrimaryKeys is null, col.IsTablePrimaryKey, confPkCol.IsConfPkCol), 0)
	,IsVersionStamp = col.IsVersionStamp
	,IsInsiktStatusColumn = isnull(confStatusCol.IsConfStatusCol, 0)
	,DefaultValue = col.DefaultValue
from
	integrationInternal.Dataset conf
		inner join ResourceColumn col on
			col.object_id = object_id(conf.DataTable)
		outer apply
		(
			select
				IsConfPkCol = 1
			from
				[dbo].[sepstring](conf.LogicalPrimaryKeys, ',') confPkCol
			where
				parsename(ltrim(rtrim(strings)), 1) = col.ColumnName
		) confPkCol
		outer apply
		(
			select
				IsConfStatusCol = 1
			from
				[dbo].[sepstring](conf.InsiktProcessStatusColumns, ',') confStatusCol
			where
				parsename(ltrim(rtrim(strings)), 1) = col.ColumnName
		) confStatusCol
		
GO
