SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure app.CreateFactDimensionPartRelations
(
	@FactTable nvarchar(256)
)
as

set @FactTable = isnull(isnull(quotename(parsename(@FactTable, 2)) + '.', '') + quotename(parsename(@FactTable, 1)), '<NULL>')

declare @NewLine char(2)
set @NewLine = CHAR(13) + CHAR(10)

if object_id(@FactTable, 'u') is null
	begin
		raiserror('Table %s does not exists in database.', 16, 10, @FactTable)
		return
	end

declare 
	@SQL nvarchar(max)
	,@Message nvarchar(max)
	
set @SQL = ''
set @Message = ''
;with DPKeyCnt as
(
	select
		dpKeys.DimensionPartTypeID
		,ColumnCnt = count(*)
	from
		app.showDimensionPartTypeKeys dpKeys
	group by
		dpKeys.DimensionPartTypeID
)
,
DPRels as
(
	select
		dpKeyCnt.DimensionPartTypeID
		,KeyColumnList = 
			stuff
			(
				(
					select
						',' + quotename(dpKeys.ColumnName)
					from
						app.showDimensionPartTypeKeys dpKeys
					where
						dpKeys.DimensionPartTypeID = dpKeyCnt.DimensionPartTypeID
					order by
						dpKeys.KeyNr
					for xml path('')
				)
				,1,1,''
			)
	from
		sys.columns factCols
			inner join app.showDimensionPartTypeKeys dpKeys on
				dpKeys.ColumnName = factCols.name
			inner join DPKeyCnt dpKeyCnt on
				dpKeyCnt.DimensionPartTypeID = dpKeys.DimensionPartTypeID
	where
		factCols.object_id = object_id(@FactTable)
	group by
		dpKeyCnt.DimensionPartTypeID
		,dpKeyCnt.ColumnCnt	
	having
		dpKeyCnt.ColumnCnt = count(*)
)
,
ExistingRels as
(
	select
		refDP.DimensionPartTypeID
	from
		sys.foreign_keys factFK
			inner join sys.tables refTab on
				refTab.object_id = factFK.referenced_object_id
			inner join app.DimensionPartType refDP on
				'base_' + refDP.Name = refTab.name
			inner join sys.foreign_key_columns fkCol on		
				fkCol.constraint_object_id = factFK.object_id
			inner join sys.columns refTabCol on
				refTabCol.object_id = factFK.referenced_object_id
				and refTabCol.column_id = fkCol.referenced_column_id
			left join app.showDimensionPartTypeKeys dpKeys on
				dpKeys.ColumnName = refTabCol.name
				and dpKeys.DimensionPartTypeID = refDP.DimensionPartTypeID
	where
		factFK.parent_object_id = object_id(@FactTable)	
	group by
		factFK.name
		,refDP.DimensionPartTypeID
	having
		sum(case when dpKeys.ColumnName is null then 1 else 0 end) = 0
)
select
	@SQL = @SQL + 
		case 
			when existingRel.DimensionPartTypeID is null then
				'alter table ' + @FactTable + ' add constraint [FK_' + parsename(@FactTable, 1) + '_dw_base_' + dp.Name + '] foreign key (' + rel.KeyColumnList + ') references ' + 
					app.GetDimensionPartTableName(rel.DimensionPartTypeID) + '(' +  rel.KeyColumnList + ')' + @NewLine
			else 
				''
		end
	,@Message = @Message +
		'* ' + dp.Name +
		case 
			when existingRel.DimensionPartTypeID is null then
				' (Created)  '
			else
				' (Existing) '
		end +
		@NewLine
		
from
	DPRels rel
		inner join app.DimensionPartType dp on
			dp.DimensionPartTypeID = rel.DimensionPartTypeID
		left join ExistingRels existingRel on
			existingRel.DimensionPartTypeID = rel.DimensionPartTypeID
	

			
if LEN(@SQL) > 0
	exec (@SQL)
	
if len(@Message) = 0
	set @Message = 'Non found!' + @NewLine
	
print 'FK Relation from ' + @FactTable + ' to DimensionParts tables'
print @Message
GO
