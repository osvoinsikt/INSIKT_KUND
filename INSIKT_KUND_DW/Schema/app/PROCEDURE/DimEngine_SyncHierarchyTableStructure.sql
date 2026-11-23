SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[DimEngine_SyncHierarchyTableStructure]
(
	@HierarchyID int
	,@Debug bit = 0
)
as
set xact_abort on
set nocount on

if @Debug is null
	set @Debug = 0
	
declare @HierarchyTableName nvarchar(256)
set @HierarchyTableName = app.GetHierarchyTableName(@HierarchyID)

if object_id(@HierarchyTableName) is null
	begin
		exec app.DimEngine_CreateHierarchyTable 
			@HierarchyID = @HierarchyID
			,@TableName = @HierarchyTableName
		return 0;
	end

declare @NewLine char(2)
set @NewLine = CHAR(13) + CHAR(10)

declare @ErrorMessage nvarchar(2000)
declare @TempNewTableName nvarchar(128)
set @TempNewTableName = '##NewDimTabTemp'

exec app.GetUniqueObjectName @TempNewTableName output

exec app.DimEngine_CreateHierarchyTable
	@HierarchyID = @HierarchyID
	,@TableName = @TempNewTableName
	,@Target = 1
	,@CreateConstraints = 0	



create table #ColumnsBefore
(
	ColumnIndex int not null 
	,Name sysname primary key
	,ColumnType varchar(20) not null
	,LevelNr int
	,LevelName nvarchar(128)
	,DataType nvarchar(100) not null
	,DefaultBinding nvarchar(100) null
)

create table #ColumnsAfter
(
	ColumnIndex int not null 
	,Name sysname primary key
	,ColumnType varchar(20) not null
	,LevelNr int
	,LevelName nvarchar(128)
	,DataType nvarchar(100) not null
	,DefaultBinding nvarchar(100) null
)

insert into #ColumnsBefore
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
	ColumnIndex
	,Name
	,ColumnType
	,LevelNr
	,LevelName
	,DataType
	,DefaultBinding
from
	app.DimEngine_HierarchyTableColumnsFromExistingTable(@HierarchyTableName) old
	
insert into #ColumnsAfter
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
	ColumnIndex = t.ColumnIndex
	,Name = t.Name
	,ColumnType = cData.ColumnType
	,LevelNr = t.LevelNr
	,LevelName = t.LevelName
	,DataType = t.DataType
	,DefaultBinding = t.DefaultBinding
from
	app.DimEngine_HierarchyTableColumnsFromExistingTable(@TempNewTableName) t
		left join app.DimEngine_HierarchyTableColumns(@HierarchyID, 1) cData on
			cData.Name = t.Name


create table #TableChanges
(
	ColumnName sysname
	,ChangeMessage nvarchar(max)
	,IsKeyColumn bit not null
)

insert into #TableChanges
(
	ColumnName
	,ChangeMessage
	,IsKeyColumn
)
select 
	ColumnName = isnull(new.Name, old.Name)
	,ChangeMessage =		
		case
			when new.Name is null then
				'Column ' + isnull(new.Name, old.Name) + ' removed in new hierarchy configuration.'
			when old.Name is null then
				'Column ' + isnull(new.Name, old.Name) + ' added in new hierarchy configuration.'
			else
				'Column ' + isnull(new.Name, old.Name) + ' Changed in new hierarchy configuraion.'
		end
		
	,IsKeyColumn = case when isnull(old.ColumnType, '') = 'KeyColumn' or isnull(new.ColumnType, '') = 'KeyColumn' then 1 else 0 end
from 
	#ColumnsBefore old
		full join #ColumnsAfter  new on
			old.Name = new.Name

where
	(old.ColumnIndex is null or new.ColumnIndex is null)
	or (old.DataType <> new.DataType)
	or (isnull(old.DefaultBinding, '') <> isnull(new.DefaultBinding, ''))
	

--
-- I de fall EmptyHeaders existerar så kan vi inte skapa FK till respektive dimensionsdelstabell eftersom 
-- hittepå-ID:n genereras för tomma rubriker som inte finns i respektive dimensionsdelstabell)
--
declare @CreateFK bit
if exists(select 1 from app.HierarchyNode where HierarchyID = @HierarchyID and EmptyHeader = 1)
	set @CreateFK = 0
else
	set @CreateFK = 1

;with 
DPRelAfter as
(
	select
		hdp.DimensionPartTypeID
	from
		app.HierarchyDimensionPartType hdp						
	where
		hdp.HierarchyID = @HierarchyID
		and object_id([app].[GetDimensionPartTableName](hdp.DimensionPartTypeID), 'U') is not null
		and @CreateFK = 1
)
,
DPRelBefore as
(
	select
		refDpt.DimensionPartTypeID
	from
		sys.foreign_keys fk
			inner join sys.tables refTab on
				refTab.object_id = fk.referenced_object_id
			inner join sys.schemas refTabSchema on
				refTabSchema.schema_id = refTab.schema_id
				and refTabSchema.name = 'dw'
			inner join app.DimensionPartType refDpt on
				'base_' + refDpt.Name = refTab.Name
	where
		fk.parent_object_id = object_id(@HierarchyTableName)
)
insert into #TableChanges
(
	ColumnName
	,ChangeMessage
	,IsKeyColumn
)
select 
	ColumnName = 'FK to ' + (select t.Name from app.DimensionPartType t where t.DimensionPartTypeID = isnull(old.DimensionPartTypeID, new.DimensionPartTypeID))
	,ChangeMessage =
		'Foreign key to dimension part ' + (select t.Name from app.DimensionPartType t where t.DimensionPartTypeID = isnull(old.DimensionPartTypeID, new.DimensionPartTypeID)) +
		case
			when new.DimensionPartTypeID is null then
				' removed in new hierarchy configuration.'
			when old.DimensionPartTypeID is null then
				' added in new hierarchy configuration.'			
		end
		
	,IsKeyColumn = 0
from 
	DPRelBefore old
		full join DPRelAfter new on
			old.DimensionPartTypeID = new.DimensionPartTypeID
where
	old.DimensionPartTypeID is null or new.DimensionPartTypeID is null

if @Debug = 1
	begin
		declare @CommentTxt nvarchar(max)
		set @CommentTxt = '--' + @NewLine
		select
			@CommentTxt = @CommentTxt + '-- ' + ChangeMessage + @NewLine
		from
			#TableChanges
			
		if @@rowcount = 0 set @CommentTxt = @CommentTxt + '-- No table changed detected.' + @NewLine
		
		set @CommentTxt = @CommentTxt + '--' + @NewLine
		print @CommentTxt
	end

declare @TruncateTableBeforeSync bit
if exists(select 1 from #TableChanges where IsKeyColumn = 1)
	begin
		declare @RowCntCheck nvarchar(1000)
		
		set @ErrorMessage = null
		select
			@ErrorMessage = ISNULL(@ErrorMessage + ' ', '') + ChangeMessage
		from
			 #TableChanges 
		where 
			IsKeyColumn = 1
			
		set @ErrorMessage = 'Unable to alter table with added or removed dimension parts or changed dimension part keys. ' + @ErrorMessage + ' Drop table ' + @HierarchyTableName + ' and try again.'
		raiserror(@ErrorMessage, 16, 10)
		return;
		set @TruncateTableBeforeSync = 1
		
	end
	
if exists(select 1 from #TableChanges)
	begin
		create table #Constraint
		(
			ID int not null identity(1,1)
			,DropConstraint nvarchar(2000)
			,CreateConstraint nvarchar(2000)
		)
		insert into #Constraint
		(
			DropConstraint
			,CreateConstraint
		)	
		select 
			DropConstraint =
				'alter table ' + quotename(schema_name(f.schema_id)) + '.' + quotename(object_name(f.parent_object_id)) + ' drop constraint ' + quotename(f.name)
			,CreateConstraint =
				'alter table ' + quotename(schema_name(f.schema_id)) + '.' + quotename(object_name(f.parent_object_id)) + ' with check add constraint ' + quotename(f.name) + 
				' foreign key ' + 
				'(' + 
					stuff
					(
						(
							select 
								',' + quotename(col_name(fc.parent_object_id, fc.parent_column_id)) 
							from 
								sys.foreign_key_columns as fc 
							where
								f.object_id = fc.constraint_object_id
							order by 
								fc.constraint_column_id
							for xml path('')
						)
						,1,1,''
					) + 
				')' + 
				' references ' + quotename(schema_name(refobj.schema_id)) + '.' + quotename(object_name(f.referenced_object_id)) + 
				' (' + 
					stuff
					(
						(
							select 
								',' + quotename(col_name(fc.referenced_object_id, fc.referenced_column_id)) 
							from 
								sys.foreign_key_columns as fc
							where 
								f.object_id = fc.constraint_object_id
							order by 
								fc.constraint_column_id
							for xml path('')
						)
						,1,1,''
					) + 
				') ' + 
				case 
					when update_referential_action_desc = 'cascade' then 
						' on update cascade'
					when update_referential_action_desc = 'set_default' then
						' on update set default'
					when update_referential_action_desc = 'set_null' then
						' on update set null' 
					else
						''
				end +
				case 
					when delete_referential_action_desc = 'cascade' then
						' on delete cascade'
					when delete_referential_action_desc = 'set_default' then
						' on delete set default'
					when delete_referential_action_desc = 'set_null'
						then ' on delete set null'
					else 
						'' 
				end
		from
			sys.foreign_keys as f
				inner join sys.objects refobj on
					refobj.object_id = f.referenced_object_id
		where
			refobj.object_id = object_id(@HierarchyTableName)
		union all
		select
			DropConstraint = 
				'alter table ' + quotename(schema_name(dc.schema_id)) + '.' + quotename(object_name(dc.parent_object_id)) + ' drop constraint ' + quotename(dc.name)
			,CreateConstraint = null
		from
			sys.default_constraints dc
		where
			dc.parent_object_id = object_id(@HierarchyTableName)
			
		--union all			
		
		--select
		--	DropConstraint = 
		--		'drop index ' + quotename(i.name) + ' on ' + quotename(s.name) + '.' + quotename(o.name)
		--	,CreateConstraint = null
		--from
		--	sys.indexes i
		--		inner join sys.objects o on
		--			o.object_id = i.object_id
		--		inner join sys.schemas s on
		--			s.schema_id = o.schema_id
		--where
		--	i.object_id = object_id(@HierarchyTableName)
	
		
		
		declare @SQL nvarchar(max)
			
		
		
		
			
		declare @ConstraintID int		
		select @ConstraintID = min(ID) from #Constraint where DropConstraint is not null
		while @ConstraintID is not null
			begin
				select @SQL = DropConstraint from #Constraint where ID = @ConstraintID
				if @Debug = 0
					exec (@SQL)
				else
					print @SQL
									
				select @ConstraintID = min(ID) from #Constraint	where ID > @ConstraintID and DropConstraint is not null
			end

		
		
		declare 
			@NrOfLevelsBefore int
			,@NrOfLevelsAfter int
		select
			@NrOfLevelsBefore = max(isnull(old.LevelNr, 0))
		from
			#ColumnsBefore old
		select
			@NrOfLevelsAfter = max(isnull(new.LevelNr, 0))			
		from
			#ColumnsAfter new 
			


		declare 
			@SQL_Insert nvarchar(max)
			,@SQL_Select nvarchar(max)
		
		select
			@SQL_Insert = ISNULL(@SQL_Insert + '	,', '	') +
				quotename(new.Name) + @NewLine
				
			,@SQL_Select = ISNULL(@SQL_Select + '	,', '	') +
				quotename(new.Name) + ' = old.' + quotename(isnull(old.Name, new.Name)) + @NewLine
		from
			#ColumnsAfter new
				left join #ColumnsBefore old on
					old.LevelName = new.LevelName										
					and old.LevelNr = 
						case 
							when @NrOfLevelsAfter < @NrOfLevelsBefore then -- borttagna nivåer
								new.LevelNr + @NrOfLevelsBefore - @NrOfLevelsAfter
							when @NrOfLevelsAfter > @NrOfLevelsBefore and new.LevelNr > @NrOfLevelsBefore then -- nya nivåer
								@NrOfLevelsBefore
						end
		where
			exists(select 1 from #ColumnsBefore colChk where colChk.Name = new.Name)
			or new.ColumnType = 'Level'
		order by
			new.ColumnIndex
		
		
		declare @NewTempHierarchyTableName nvarchar(256)
		set @NewTempHierarchyTableName = @HierarchyTableName
		set @NewTempHierarchyTableName = isnull(quotename(parsename(@NewTempHierarchyTableName, 2)) + '.', '') + quotename(parsename(@NewTempHierarchyTableName, 1) + '_Tmp')	
		exec app.GetUniqueObjectName @NewTempHierarchyTableName output
		
		
		exec app.DimEngine_CreateHierarchyTable
			@HierarchyID = @HierarchyID
			,@TableName = @NewTempHierarchyTableName
			,@CreateConstraints = 0
			,@Debug = @Debug
		
		select @SQL = 
			'insert into ' + @NewTempHierarchyTableName + @NewLine +
			'(' + @NewLine +
				@SQL_Insert +
			')' + @NewLine +
			'select' + @NewLine +
				@SQL_Select +
			'from' + @NewLine +
			'	' + @HierarchyTableName + ' old' + @NewLine


		if @Debug = 0
			exec (@SQL)
		else
			print @SQL
		
		select @SQL = 'drop table ' + @HierarchyTableName
		if @Debug = 0
			exec (@SQL)
		else 
			print @SQL
		
		
		set @SQL = 'exec sp_rename ''' + @NewTempHierarchyTableName + ''', ''' + parsename(@HierarchyTableName, 1) + ''''
		if @Debug = 0
			begin
				exec (@SQL)
				exec app.DimEngine_CreateHierarchyTableConstraints
					@HierarchyID = @HierarchyID
					,@TableName = @HierarchyTableName
					,@Target = 1
			end			
		else
			begin			
				print @SQL
				exec app.DimEngine_CreateHierarchyTableConstraints
					@HierarchyID = @HierarchyID
					,@TableName = @HierarchyTableName
					,@Target = 1
					,@Debug = 1
			end
				
		select @ConstraintID = min(ID) from #Constraint where CreateConstraint is not null
		while @ConstraintID is not null
			begin
				select @SQL = CreateConstraint from #Constraint where ID = @ConstraintID
				if @Debug = 0
					exec (@SQL)
				else
					print @SQL
				select @ConstraintID = min(ID) from #Constraint	where ID > @ConstraintID and CreateConstraint is not null
			end

		drop table #Constraint
	end
	

exec ('drop table ' + @TempNewTableName)
drop table #ColumnsAfter
drop table #ColumnsBefore
GO
