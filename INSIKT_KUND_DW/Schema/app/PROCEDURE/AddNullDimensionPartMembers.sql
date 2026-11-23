SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Author:		TRIMMA Affärsutveckling AB
-- Description:	Add null members
---------------------------------------------------------------------------------------------
-- OBS!
-- DO NOT CALL THIS PROCEDURE!
-- Set the flag AddNullMembers of the table app.DimensionPartType to add null members. This 
-- procedure will then be called every time SyncDimensionPart is executed.
-- ==========================================================================================
CREATE procedure [app].[AddNullDimensionPartMembers]
(
	@DimensionPartTypeID int
	,@Debug bit = 0
) as
set nocount on;

declare @ProcName sysname, @TranCount int
set @ProcName = coalesce(object_name(@@procid), 'No procedure name available')
set @TranCount = @@TRANCOUNT

-- SET XACT_ABORT ON will cause the transaction to be uncommittable
-- when the constraint violation occurs and other runtime errors occure. 
set xact_abort on;
set nocount on

declare @NewLine char(2)
set @NewLine = CHAR(13) + CHAR(10)

if @Debug is null set @Debug = 0

begin try

	declare @DimensionPartTable varchar(512)
	select
		@DimensionPartTable = app.GetDimensionPartTableName(@DimensionPartTypeID)
		
	from
		app.DimensionPartType t
	where
		t.DimensionPartTypeID = @DimensionPartTypeID


	create table #Columns
	(
		ColNr int not null identity(1,1)
		,ColumnName sysname collate database_default
		--,ColumnType varchar(5) 
		,SQL_ValueExpression nvarchar(1000) collate database_default
		,ColumnTypeCast nvarchar(128) collate database_default
	)

	insert into #Columns(ColumnName, ColumnTypeCast)
	select
		ColumnName = c.name
		,ColumnTypeCast = 
			case 
				when t.name in ('ntext','nvarchar','nchar') then
					t.name + '(' + case when c.max_length = -1 then 'max' else cast(c.max_length / 2 as nvarchar(12)) end + ')'
				when t.name in ('text','varchar','char', 'binary', 'varbinary') then
					t.name + '(' + case when c.max_length = -1 then 'max' else  cast(c.max_length as nvarchar(12)) end + ')'
				when t.name in ('decimal', 'numeric') then
					t.name + '(' + cast(c.precision as nvarchar(12)) + ',' + cast(c.scale as nvarchar(12)) + ')'
				when t.name in ('float') then
					t.name + '(' + cast(c.precision as nvarchar(12))+ ')'
				else
					t.name
			end			
	from
		sys.columns c
			inner join sys.types t on
				t.user_type_id = c.user_type_id
	where
		c.object_id = object_id(@DimensionPartTable , 'u')
		and c.name not in
			(
				'CreatedBy'
				,'CreatedDate'
				,'ModifiedBy'
				,'ModifiedDate'
				,'ModifiedDate'
				,'IsDeleted'
			)
	
	
	create table #RelatedTypes
	(
		RelNr int not null identity(1,1)
		,DimensionPartTypeID int not null
		,RelationTypeID char(3) collate database_default not null
		
	)
	insert into #RelatedTypes(DimensionPartTypeID, RelationTypeID)
	select
		r.ParentDimensionPartTypeID
		,r.RelationTypeID
	from
		app.showDimensionPartTypeRelation r
	where
		r.DimensionPartTypeID = @DimensionPartTypeID
	order by
		r.RelationTypeID desc

	create table #RelatedKeyColumns
	(
		DimensionPartTypeID int not null
		,ColumnName sysname	 collate database_default
		,KeyNr int not null
		,LastKeyNr int not null
		,RelationTypeID char(3) collate database_default not null
	)
	insert into #RelatedKeyColumns
	(
		DimensionPartTypeID
		,ColumnName
		,KeyNr
		,LastKeyNr
		,RelationTypeID
	)
	select 		
		DimensionPartTypeID = pK.DimensionPartTypeID
		,ColumnName = pK.ColumnName
		,KeyNr = pK.KeyNr
		,LastKeyNr = pK.LastKeyNr
		,RelationTypeID = r.RelationTypeID
	from
		#RelatedTypes r
			inner join app.showDimensionPartTypeKeys pK on
				pK.DimensionPartTypeID = r.DimensionPartTypeID


	--
	-- Uppdatera expression för nyckel-relatioenr
	--		
	;with KeyRelatedKeyColumns as
	(
		select
			c.ColumnName
			,DimensionPartTypeID = min(c.DimensionPartTypeID)
		from
			#RelatedKeyColumns c
		where
			c.RelationTypeID = 'KEY'
		group by
			c.ColumnName
	)
	update c set
		SQL_ValueExpression = quotename(t.Name) + '.' + quotename(c.ColumnName)
	from
		#Columns c	
			inner join KeyRelatedKeyColumns kc on
				kc.ColumnName = c.ColumnName
			inner join app.DimensionPartType t on
				t.DimensionPartTypeID = kc.DimensionPartTypeID
				
	--
	-- Uppdatera expression för grupperings-relationer
	--
	;with RelatedKeyColumns as
	(
		select
			c.ColumnName
		from
			#RelatedKeyColumns c	
		group by
			c.ColumnName
		union select
			isnull(parsename(t.IDColumnName, 1), t.Name + 'ID')
		from
			app.DimensionPartType t
		where
			t.DimensionPartTypeID = @DimensionPartTypeID
			
	)
	update c set
		SQL_ValueExpression = '-' + cast(t.DimensionPartTypeID as varchar(12))
	from
		#Columns c
			inner join RelatedKeyColumns kc on
				kc.ColumnName = c.ColumnName
			inner join app.DimensionPartType t on
				isnull(parsename(t.IDColumnName, 1), t.Name + 'ID') = kc.ColumnName
	where
		c.SQL_ValueExpression is null -- För att exkludera gemensamma nyckelkolumner




	update c set
		SQL_ValueExpression = valueExpr.SQLValueExpression
	from
		#Columns c
			inner join app.NullDimensionPartDefaults valueExpr on
				valueExpr.DimensionPartTypeID = @DimensionPartTypeID
				and c.ColumnName = parsename(valueExpr.ColumnName, 1)
	--where
	--	c.SQL_ValueExpression is null -- Saker som redan är satta ska ej gå att ändra på.


	

	declare 
		@DefaultName nvarchar(max)
		,@DefaultDisplayName nvarchar(max)

	select
		@DefaultName = isnull(@DefaultName + ' + '', '' + ', '') +
			quotename(t.Name) + '.[Name]'
		,@DefaultDisplayName = isnull(@DefaultDisplayName + ' + '', '' + ', '') +
			quotename(t.Name) + '.[DisplayName]'
	from
		#RelatedTypes r
			inner join app.DimensionPartType t on
				t.DimensionPartTypeID = r.DimensionPartTypeID
	where
		r.RelationTypeID = 'KEY'



	select
		@DefaultName = '''Ej angivet' + isnull(' ('' + ' + @DefaultName + ' + '')', '') + ''''
		,@DefaultDisplayName = '''Ej angivet' + isnull(' ('' + ' + @DefaultDisplayName + ' + '')', '') + ''''


	update c set
		SQL_ValueExpression = @DefaultName
	from
		#Columns c		
	where
		c.SQL_ValueExpression is null -- Saker som redan är satta ska ej gå att ändra på.
		and c.ColumnName = 'Name'

	update c set
		SQL_ValueExpression = @DefaultDisplayName
	from
		#Columns c		
	where
		c.SQL_ValueExpression is null -- Saker som redan är satta ska ej gå att ändra på.
		and c.ColumnName = 'DisplayName'

	--
	-- Kolumner som ännu inte fått något värde men som har ett default constraint ska excluderas i 
	-- inserten så att dess defaultvärde antas.
	--
	delete from c
	from		
		sys.tables tab
			inner join sys.default_constraints defConst on
				defConst.parent_object_id = tab.object_id
			inner join sys.columns tabColWithDefConst on
				tabColWithDefConst.object_id = tab.object_id
				and tabColWithDefConst.column_id = defConst.parent_column_id
			inner join #Columns c on
				c.ColumnName =tabColWithDefConst.name
				and c.SQL_ValueExpression is null
	where
		tab.object_id = object_id(app.GetDimensionPartTableName(@DimensionPartTypeID))
			


	declare @SQL nvarchar(max)
	select
		@SQL = 
			'select' + @NewLine
			
	select
		@SQL = @SQL + '	' + case when row_number() over(order by c.ColNr) > 1 then ',' else '' end +
			quotename(c.ColumnName) + ' = cast(' + isnull(c.SQL_ValueExpression, 'null') + ' as ' + c.ColumnTypeCast + ')' + @NewLine
	from
		#Columns c
	order by
		c.ColNr


			
	select
		@SQL = @SQL +	
			'into #NullMembers' + @NewLine
			
			
	select
		@SQL = @SQL + case when rt.RelNr = 1 then 'from' + @NewLine + '	' else '	,' end +
			app.GetDimensionPartTableName(t.DimensionPartTypeID) + ' as ' + quotename(t.Name) + @NewLine
	from
		#RelatedTypes rt
			inner join app.DimensionPartType t on
				t.DimensionPartTypeID = rt.DimensionPartTypeID
	where
		rt.RelationTypeID = 'KEY'
	order by
		 rt.RelNr
		

	;with SharedKeyColumnsData as
	(
		select distinct
			DimensionPartTypeID1 = case when keyCol.DimensionPartTypeID < sharedKeyCol.DimensionPartTypeID then keyCol.DimensionPartTypeID else sharedKeyCol.DimensionPartTypeID end
			,DimensionPartTypeID2 = case when keyCol.DimensionPartTypeID > sharedKeyCol.DimensionPartTypeID then keyCol.DimensionPartTypeID else sharedKeyCol.DimensionPartTypeID end
			,ColumnName = keyCol.ColumnName
		from
			#RelatedKeyColumns keyCol			
				inner join #RelatedKeyColumns sharedKeyCol on
					sharedKeyCol.ColumnName = keyCol.ColumnName
					and sharedKeyCol.DimensionPartTypeID <> keyCol.DimensionPartTypeID
					and sharedKeyCol.RelationTypeID = 'KEY'
		where
			keyCol.RelationTypeID = 'KEY'
	)
	,
	 SharedKeyColumns as
	(
		select distinct
			RowNr = row_number() over (order by DimensionPartTypeID1, DimensionPartTypeID2)
			,DimensionPartTypeID1
			,DimensionPartTypeID2
			,ColumnName
		from
			SharedKeyColumnsData
	)
	select
		@SQL = @SQL + case when k.RowNr = 1 then 'where' + @NewLine + '	' else '	and ' end +
			quotename(dp1.Name) + '.' + quotename(k.ColumnName) + ' = ' + quotename(dp2.Name) + '.' + quotename(k.ColumnName) + @NewLine
	from
		SharedKeyColumns k				
			inner join app.DimensionPartType dp1 on
				dp1.DimensionPartTypeID = k.DimensionPartTypeID1
			inner join app.DimensionPartType dp2 on
				dp2.DimensionPartTypeID = k.DimensionPartTypeID2
	order by
		k.RowNr
				
				
	select
		@SQL = @SQL + @NewLine +
			'exec app.SyncTable' + @NewLine +
			'	@SourceTable = ''#NullMembers''' + @NewLine +
			'	,@TargetTable = ''' + @DimensionPartTable + '''' + @NewLine +	
			'	,@TargetFilter = ''' + quotename(isnull(parsename(t.IDColumnName, 1), t.Name + 'ID')) + ' = -' + cast(t.DimensionPartTypeID as varchar(12)) + '''' + @NewLine +
			'	,@SupressWarnings = 1' + @NewLine +
			@NewLine +
			'drop table #NullMembers' + @NewLine
	from
		app.DimensionPartType t
	where
		t.DimensionPartTypeID = @DimensionPartTypeID
		

	if @Debug = 0
		begin
			if @TranCount = 0 begin tran
			exec (@SQL)
			if @TranCount = 0 commit tran
		end
	else
		exec app.PrintMax @SQL

	drop table #RelatedKeyColumns	
	drop table #RelatedTypes
	drop table #Columns
	
end try
begin catch
	--
	-- Rollback transactions
	--
	if @TranCount = 0 and @@trancount > 0 rollback tran
	exec app.ReThrowError
end catch
GO
