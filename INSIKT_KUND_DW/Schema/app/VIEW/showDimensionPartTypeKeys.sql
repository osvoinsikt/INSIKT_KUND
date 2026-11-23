SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [app].[showDimensionPartTypeKeys] as
with PrimaryKeyBuilder as
(
	select
		DimensionPartTypeID = t.DimensionPartTypeID		
		,ParentDimensionPartTypeID = t.DimensionPartTypeID
		,DPDistance = 0
		,object_id = object_id(t.TableName)
		,pk_index_id = pk.index_id		
	from
		app.DimensionPartType t			
			left join sys.indexes pk on
				pk.object_id = object_id(t.TableName)
				and pk.is_primary_key = 1
	where
		t.DimensionPartTypeID > 0
	union all
	select
		DimensionPartTypeID = t.DimensionPartTypeID		
		,ParentDimensionPartTypeID = r.ParentDimensionPartTypeID
		,DPDistance = t.DPDistance + 1
		,object_id = t.object_id		
		,pk_index_id = t.pk_index_id		
	from
		PrimaryKeyBuilder t
			inner join app.showDimensionPartTypeRelation r on
				r.DimensionPartTypeID = t.ParentDimensionPartTypeID
				and r.RelationTypeID = 'KEY'
			

)
select
	DimensionPartTypeID = k.DimensionPartTypeID
	,ColumnName = isnull(parsename(t.IDColumnName, 1), t.Name + 'ID')
	,KeyNr = row_number() over (partition by k.DimensionPartTypeID order by pkCol.key_ordinal, case when k.ParentDimensionPartTypeID = k.DimensionPartTypeID then 0 else 1 end, k.ParentDimensionPartTypeID)
	,LastKeyNr = row_number() over (partition by k.DimensionPartTypeID order by pkCol.key_ordinal desc, case when k.ParentDimensionPartTypeID = k.DimensionPartTypeID then 0 else 1 end desc, k.ParentDimensionPartTypeID desc)
	,MemberIDOrder = cast(row_number() over (partition by k.DimensionPartTypeID order by k.DPDistance desc, k.ParentDimensionPartTypeID desc) as int)	
from
	PrimaryKeyBuilder k
		inner join app.DimensionPartType t on
			t.DimensionPartTypeID = k.ParentDimensionPartTypeID	
		left join sys.columns c on
			c.object_id = k.object_id
			and c.name = parsename(t.IDColumnName, 1)
		left join sys.index_columns pkCol on
			pkCol.column_id = c.column_id
			and pkCol.object_id = k.object_id
			and pkCol.index_id = k.pk_index_id
group by 
	k.DimensionPartTypeID
	,k.ParentDimensionPartTypeID
	,t.IDColumnName
	,t.Name
	,k.DPDistance
	,pkCol.key_ordinal
GO
