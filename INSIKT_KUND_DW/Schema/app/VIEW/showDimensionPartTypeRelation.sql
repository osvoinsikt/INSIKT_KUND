SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [app].[showDimensionPartTypeRelation] as
select	
	DimensionPartTypeID = tabType.DimensionPartTypeID
	,ParentDimensionPartTypeID = pkTabType.DimensionPartTypeID
	,RelationTypeID = 
		case min(case when tabPKIxCol.column_id is null then 0 else 1 end)
			when 0 then 'GRP'
			when 1 then 'KEY'
		end
	,FKRel = 1
from 
	sys.foreign_keys fk
		inner join sys.objects tab on
			tab.object_id = fk.parent_object_id	
			and tab.schema_id = schema_id('dw')
		inner join sys.objects pkTab on
			pkTab.object_id = fk.referenced_object_id
			and pkTab.schema_id = tab.schema_id
		inner join app.DimensionPartType pkTabType on
			'base_' + pkTabType.Name = pkTab.name
		inner join app.DimensionPartType tabType on
			'base_' + tabType.Name = tab.name
			
		inner join sys.foreign_key_columns fkCol on
			fkCol.constraint_object_id = fk.object_id
		inner join sys.columns pkTabCol on
			pkTabCol.object_id = fk.referenced_object_id 			
			and pkTabCol.column_id = fkCol.referenced_column_id
		left join sys.columns tabCol on
			tabCol.object_id = fk.parent_object_id 			
			and tabCol.column_id = fkCol.parent_column_id
			--
			-- I de fall kolumnerna i relationen inte är samma i FK och PK kommer denn left join inte att få
			-- någon träff och having-clausen nedan filtrerar bort relationen.
			--
			and tabCol.name = pkTabCol.name 
		left join sys.indexes tabPKIx on
			tabPKIx.object_id = tab.object_id
			and tabPKIx.is_primary_key = 1
		left join sys.index_columns tabPKIxCol on
			tabPKIxCol.object_id = tab.object_id 
			and tabPKIxCol.index_id = tabPKIx.index_id
			and tabPKIxCol.column_id = fkCol.parent_column_id
group by
	tabType.DimensionPartTypeID
	,pkTabType.DimensionPartTypeID
having
	--
	-- Filtrera bort relationer som var kolumnnamn inte stämmer överens.
	--
	min(isnull(tabCol.column_id, -1)) > -1

union select
	DimensionPartTypeID = nonFkRel.DimensionPartTypeID
	,ParentDimensionPartTypeID = nonFkRel.ParentDimensionPartTypeID
	,RelationTypeID  = nonFkRel.DimensionPartTypeRelationTypeID
	,FKRel = 0
from
	app.DimensionPartTypeNonFKRelation nonFkRel
GO
