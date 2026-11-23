SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[DimEngine_HierarchyTableColumnsFromExistingTable]
(
	@HierarchyTable nvarchar(256)
)
returns
@Columns table
(
	ColumnIndex int not null 
	,Name sysname	
	,ColumnType varchar(20) not null
	,LevelNr int
	,LevelName nvarchar(128)
	,DataType nvarchar(100) not null
	,DefaultBinding nvarchar(100) null
)
as
begin
	declare @ObjectFQN nvarchar(256)
	select 
		@ObjectFQN = 
			case 
				when left(parsename(@HierarchyTable, 1), 1) = '#' then
					'tempdb.' + isnull(quotename(parsename(@HierarchyTable, 2)), '') + '.' + quotename(parsename(@HierarchyTable, 1))
				else
					@HierarchyTable
			end
	
	if left(parsename(@HierarchyTable, 1), 1) = '#'
		with 
		LevelColumns as
		(
			select
				Name = c.name
				,LevelNr = cast(substring(c.name, 2, CHARINDEX('_', c.name) - 2) as int)
				,LevelColumnName = right(c.name, len(c.name) - charindex('_', c.name))			
			from
				tempdb.sys.columns c with (nolock)
					inner join tempdb.sys.types t with (nolock) on
						t.user_type_id = c.user_type_id
			where
				c.object_id = object_id(@ObjectFQN)
				and c.name like 'L[0-9]%'
				and (charindex('_', c.name) - 2) >= 1
				and isnumeric(substring(c.name, 2, CHARINDEX('_', c.name) - 2)) = 1
		)
		insert into @Columns
		(
			ColumnIndex
			,Name
			,ColumnType
			,LevelNr
			,LevelName
			,DataType
			,DefaultBinding
		)	
		select
			ColumnIndex = c.column_id
			,Name = c.name
			,ColumnType = 
				case 
					when pkIxCol.column_id is not null then
						'KeyColumn'
					when lc.LevelNr is not null then
						'Level'
					when c.name in ('CreatedBy','CreatedDate','ModifiedBy','ModifiedDate') then
						'Audit'				
					else
						'Unknown' -- För att synka tabellstruktur som är denna funktions huvudsyfta är bara typerna level och key interesanta.
				end
			,LevelNr = lc.LevelNr
			,LevelName = lc.LevelColumnName
			,DataType = t.name +
				case
					when t.name like '%char' then
						'(' + 
							cast(case when left(t.name, 1) = 'n' then c.max_length / 2 else c.max_length end as nvarchar(12)) +
						')'
					when t.name in ('decimal','numeric') then
						'(' +
							cast(isnull(c.precision, 18) as nvarchar(12)) + 
							',' +
							cast(isnull(c.scale, 0) as nvarchar(12)) + 
						')'
					else
						''
					end
				+ case when c.is_nullable = 1 then ' null' else ' not null' end
			,DefaultBinding = 
				case 
					when left(cDefConstraint.definition, 1) = '(' and RIGHT(cDefConstraint.definition, 1) = ')' then
						substring(cDefConstraint.definition,2, len(cDefConstraint.definition) - 2)
					else
						cDefConstraint.definition
				end
		from
			tempdb.sys.columns c with (nolock)
				inner join tempdb.sys.types t with (nolock) on
					t.user_type_id = c.user_type_id
				left join tempdb.sys.objects pk with (nolock) on
					pk.parent_object_id = c.object_id
					and pk.type = 'PK'
				left join tempdb.sys.indexes pkIx with (nolock) on
					pkIx.object_id = pk.parent_object_id
					and pkIx.is_primary_key = 1
				left join tempdb.sys.index_columns pkIxCol with (nolock) on
					pkIxCol.object_id = pk.parent_object_id
					and pkIxCol.index_id = pkIx.index_id
					and pkIxCol.column_id = c.column_id
				left join tempdb.sys.default_constraints cDefConstraint with (nolock) on
					cDefConstraint.parent_object_id = c.object_id
					and cDefConstraint.parent_column_id = c.column_id
					and cDefConstraint.type = 'D'
				left join LevelColumns lc on 
					lc.Name = c.name
		where
			c.object_id = object_id(@ObjectFQN)
			and c.is_computed = 0
	else
		with 
		LevelColumns as
		(
			select
				Name = c.name
				,LevelNr = cast(substring(c.name, 2, CHARINDEX('_', c.name) - 2) as int)
				,LevelColumnName = right(c.name, len(c.name) - charindex('_', c.name))			
			from
				sys.columns c
					inner join sys.types t on
						t.user_type_id = c.user_type_id
			where
				c.object_id = object_id(@ObjectFQN)
				and c.name like 'L[0-9]%'
				and (charindex('_', c.name) - 2) >= 1
				and isnumeric(substring(c.name, 2, CHARINDEX('_', c.name) - 2)) = 1
		)
		insert into @Columns
		(
			ColumnIndex
			,Name
			,ColumnType
			,LevelNr
			,LevelName
			,DataType
			,DefaultBinding
		)	
		select
			ColumnIndex = c.column_id
			,Name = c.name
			,ColumnType = 
				case 
					when pkIxCol.column_id is not null then
						'KeyColumn'
					when lc.LevelNr is not null then
						'Level'
					when c.name in ('CreatedBy','CreatedDate','ModifiedBy','ModifiedDate') then
						'Audit'				
					else
						'Unknown' -- För att synka tabellstruktur som är denna funktions huvudsyfta är bara typerna level och key interesanta.
				end
			,LevelNr = lc.LevelNr
			,LevelName = lc.LevelColumnName
			,DataType = t.name +
				case
					when t.name like '%char' then
						'(' + 
							cast(case when left(t.name, 1) = 'n' then c.max_length / 2 else c.max_length end as nvarchar(12)) +
						')'
					when t.name in ('decimal','numeric') then
						'(' +
							cast(isnull(c.precision, 18) as nvarchar(12)) + 
							',' +
							cast(isnull(c.scale, 0) as nvarchar(12)) + 
						')'
					else
						''
					end
				+ case when c.is_nullable = 1 then ' null' else ' not null' end
			,DefaultBinding = 
				case 
					when left(cDefConstraint.definition, 1) = '(' and RIGHT(cDefConstraint.definition, 1) = ')' then
						substring(cDefConstraint.definition,2, len(cDefConstraint.definition) - 2)
					else
						cDefConstraint.definition
				end
		from
			sys.columns c
				inner join sys.types t on
					t.user_type_id = c.user_type_id
				left join sys.objects pk on
					pk.parent_object_id = c.object_id
					and pk.type = 'PK'
				left join sys.indexes pkIx on
					pkIx.object_id = pk.parent_object_id
					and pkIx.is_primary_key = 1
				left join sys.index_columns pkIxCol on
					pkIxCol.object_id = pk.parent_object_id
					and pkIxCol.index_id = pkIx.index_id
					and pkIxCol.column_id = c.column_id
				left join sys.default_constraints cDefConstraint on
					cDefConstraint.parent_object_id = c.object_id
					and cDefConstraint.parent_column_id = c.column_id
					and cDefConstraint.type = 'D'
				left join LevelColumns lc on 
					lc.Name = c.name
		where
			c.object_id = object_id(@ObjectFQN)
			and c.is_computed = 0

	return;
end
GO
