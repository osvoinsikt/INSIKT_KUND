SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[CreateFactHierarchyRelation]
(
	@FactTable nvarchar(256)
	,@HierarchyID int
)
as
set nocount on

declare @NewLine char(2)
set @NewLine = CHAR(13) + CHAR(10)



set @FactTable = isnull(isnull(quotename(parsename(@FactTable, 2)) + '.', '') + quotename(parsename(@FactTable, 1)), '<NULL>')

declare @HierarchyTable nvarchar(256)
select @HierarchyTable = app.GetHierarchyTableName(@HierarchyID)


if object_id(@FactTable, 'u') is null
	begin
		raiserror('Table %s does not exists in database.', 16, 10, @FactTable)
		return
	end
	
if object_id(@HierarchyTable) is null
	begin
		raiserror('Hierarchy with ID %i (%s) not found.', 16, 10, @HierarchyID, @HierarchyTable)
		return
	end

declare 
	@SQL nvarchar(max)
	,@SQL_2 nvarchar(max)
	,@Message nvarchar(max)
	
set @SQL = null
set @Message = ''


select
	--tabPkCol.name, factCols.name
	@SQL = isnull(@SQL + ',', '') + quotename(tabPkCol.name)
	,@Message = @Message + case when factCols.name is null then 'Column ' + tabPkCol.name + ' missing in table ' + @FactTable + '.' + @NewLine else '' end
from
	sys.tables tab
		inner join sys.indexes pkIndex on
			pkIndex.object_id = tab.object_id
			and pkIndex.is_primary_key = 1
		inner join sys.index_columns pkIndexCol on
			pkIndexCol.object_id = tab.object_id 
			and pkIndexCol.index_id = pkIndex.index_id
		inner join sys.columns tabPkCol on
			tabPkCol.object_id = tab.object_id
			and tabPkCol.column_id = pkIndexCol.column_id			
		left join sys.columns factCols on
			factCols.name = tabPkCol.name
			and factCols.object_id = object_id(@FactTable)
where
	tab.object_id = object_id(@HierarchyTable)
order by
	pkIndexCol.index_column_id
	
if len(@Message) > 0
	begin
		raiserror(@Message, 16, 10)
		return
	end

--
-- Kontrollera om FK redan finns
--
declare @ConstraintName nvarchar(256)

select
	@ConstraintName =  fk.name
from
	sys.foreign_keys fk	
where
	fk.parent_object_id = object_id(@FactTable)
	and fk.referenced_object_id = object_id(@HierarchyTable)

if @@rowcount > 1
	begin		
		raiserror('There are more than one existing FK from table %s to %s.', 16, 10, @FactTable, @HierarchyTable)
		return
	end
if @ConstraintName is not null
	begin
		--
		-- Verifera att nycklarna perkar på samtliga PK-kolumner
		--
		if exists
		(			
			select
				1
			from
				(
					select
						col.name
					from
						sys.foreign_keys fk
							inner join sys.foreign_key_columns fkCol on
								fkCol.constraint_object_id = fk.object_id
							inner join sys.columns col on
								col.object_id = fkCol.referenced_object_id
								and col.column_id = fkCol.referenced_column_id
					where
						fk.parent_object_id = object_id(@FactTable)
						and fk.referenced_object_id = object_id(@HierarchyTable)
				) fk
					full join
					(
						select
							tabPkCol.name
						from
							sys.indexes pkIndex						
								inner join sys.index_columns pkIndexCol on
									pkIndexCol.object_id = pkIndex.object_id
									and pkIndexCol.index_id = pkIndex.index_id
								inner join sys.columns tabPkCol on
									tabPkCol.object_id = pkIndex.object_id
									and tabPkCol.column_id = pkIndexCol.column_id								
						where
							pkIndex.object_id = object_id(@HierarchyTable)
							and pkIndex.is_primary_key = 1
					) pk on
						pk.name = fk.name
			where
				fk.name is null or pk.name is null
		) 
			begin
				--
				-- FK:n är ej korrekt
				--
				raiserror ('Foreign keys columns in existing foreign key %s does not match dimension primary key.', 16, 10, @ConstraintName)
				return
			end
		else
			begin
				--
				-- Hittad FK perkar redan korrekt till dimensionstabellen			
				--
				print 'FK Relation from ' + @FactTable + ' to ' + @HierarchyTable + ' already exists with the name ' + @ConstraintName
				return 
			end
	end

set @ConstraintName = 'FK_' + isnull(replace(parsename(@FactTable, 2), ' ', '_') + '_', '') + replace(parsename(@FactTable, 1), ' ', '_')
exec app.GetUniqueObjectName @ConstraintName out

select
	@SQL = 
		'ALTER TABLE ' + @FactTable + '  WITH CHECK ADD  CONSTRAINT ' + @ConstraintName + ' FOREIGN KEY(' + @SQL + ')' + @NewLine +
		'REFERENCES ' + @HierarchyTable + ' (' + @SQL + ')'

exec (@SQL)
print 'FK Relation from ' + @FactTable + ' to ' + @HierarchyTable + ' created.'
GO
