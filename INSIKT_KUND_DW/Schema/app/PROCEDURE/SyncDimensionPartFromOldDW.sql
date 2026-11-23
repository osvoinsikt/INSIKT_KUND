SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[SyncDimensionPartFromOldDW]
(
	@DimensionPartTypeID int
	,@ChangesBy nvarchar(50) = null
	,@Debug bit = null
	,@ParentEventID int = null
	
	,@SourceDB varchar(100) = null
	
) as
set nocount on

-- SET XACT_ABORT ON will cause the transaction to be uncommittable
-- when the constraint violation occurs and other runtime errors occure. 
set xact_abort on;

--
-- Save proceudre name and number of transactions to local variables @ProcName and @TranCount
-- The reason of @ProcName is to ease copy paste between procedures.
--
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount


if @Debug is null set @Debug = 0

begin try	
	declare @DimensionPartTable varchar(512)
	declare @TargetFiler nvarchar(max)
	declare @DimensionPartTypeName nvarchar(100)
	declare @AddNullMembers bit
	select
		@DimensionPartTable = app.GetDimensionPartTableName(t.DimensionPartTypeID)
		,@TargetFiler = case when t.AddNullMembers = 1 then quotename(isnull(parsename(t.IDColumnName, 1), t.Name + 'ID')) + ' >= 0'  else null end
		,@DimensionPartTypeName = t.Name
		,@AddNullMembers = t.AddNullMembers
	from
		app.DimensionPartType t		
	where
		t.DimensionPartTypeID = @DimensionPartTypeID
		
	if @@rowcount = 0		
		raiserror('DimensionPartTypeID %s does not exist.', 16, 10, @DimensionPartTypeID)
			
	if isnull(@Debug, 0) = 0
		exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output
			,@EventObject = @ProcName
			,@EventTitle = @DimensionPartTypeName
			,@Description = null


	
	
	
	
	
	if @SourceDB is null or LEN(@SourceDB) = 0
		set @SourceDB = ''
	else
		set @SourceDB = @SourceDB + '.'
	
	declare 
		@SrcDimensionPartTypeID int

	select
		@DimensionPartTypeName = t.Name	
	from
		app.DimensionPartType t
	where
		t.DimensionPartTypeID = @DimensionPartTypeID
	if @@ROWCOUNT = 0
		raiserror('DimensionPartTypeID = %i does not exist in app.DimensionPartType', 16, 10, @DimensionPartTypeID)



	declare @NewLine char(2)
	set @NewLine = char(13) + char(10)


	declare @tmpSQL varchar(max)
	
	
	create table #SrcDimensionPartType(
		[ID] [int] not null,
		[DataTypeID] [char](3) not null,
		[Name] [nvarchar](100) not null,
		[Description] [nvarchar](500) null,
		[IDColumnName] [nvarchar](100) null,
	)
	select @tmpSQL = 
		'select' + @NewLine +
		'	[ID], [DataTypeID], [Name], [Description], [IDColumnName]' + @NewLine +
		'from' + @NewLine +
		'	' + @SourceDB + 'dbo.base_DimensionPartType' + @NewLine
		

	insert into #SrcDimensionPartType
	exec (@tmpSQL)

	if (select COUNT(*) from #SrcDimensionPartType where Name = @DimensionPartTypeName) <> 1
		raiserror('Name = %s does not exist in %sdbo.base_DimensionPartType', 16, 10, @DimensionPartTypeName, @SourceDB)
		
	select @SrcDimensionPartTypeID = ID from #SrcDimensionPartType where Name = @DimensionPartTypeName

	create table #SrcDimensionPartAttributeType(
		[ID] [int] NOT NULL,
		[Name] [nvarchar](100) NOT NULL,
		[Description] [nvarchar](150) NULL
	 )
	select @tmpSQL = 
		'select' + @NewLine +
		'	[ID], [Name], [Description]' + @NewLine +
		'from' + @NewLine +
		'	' + @SourceDB + 'dbo.base_DimensionPartAttributeType' + @NewLine
	insert into #SrcDimensionPartAttributeType
	exec (@tmpSQL)


	create table #SrcDimensionPartTypeAttributeTypeRelation(
		[DimensionPartTypeID] [int] NOT NULL,
		[DimensionPartAttributeTypeID] [int] NOT NULL	
	)
	select @tmpSQL = 
		'select' + @NewLine +
		'	[DimensionPartAttributeTypeID], [DimensionPartAttributeTypeID]' + @NewLine +
		'from' + @NewLine +
		'	' + @SourceDB + 'dbo.base_DimensionPartTypeAttributeTypeRelation' + @NewLine
	insert into #SrcDimensionPartTypeAttributeTypeRelation
	exec (@tmpSQL)

	create table #SrcDimensionPartTypeRelation(
		[DimensionPartTypeID] [int] NOT NULL,
		[IsPartOfDimensionPartTypeID] [int] NOT NULL,
		[RelationTypeID] [char](3) NOT NULL 
	)
	select @tmpSQL = 
		'if exists(select 1 from ' + @SourceDB + 'sys.columns where object_id = OBJECT_ID(''' + @SourceDB + 'dbo.base_DimensionPartTypeRelation'') and name = ''RelationTypeID'')' + @NewLine +
		'	select' + @NewLine +
		'		[DimensionPartTypeID], [IsPartOfDimensionPartTypeID], [RelationTypeID]' + @NewLine +
		'	from' + @NewLine +
		'		' + @SourceDB + 'dbo.base_DimensionPartTypeRelation' + @NewLine +
		'else' + @NewLine +
		'	select' + @NewLine +
		'		[DimensionPartTypeID], [IsPartOfDimensionPartTypeID], [RelationTypeID] = ''KEY''' + @NewLine +
		'	from' + @NewLine +
		'		' + @SourceDB + 'dbo.base_DimensionPartTypeRelation' + @NewLine
	insert into #SrcDimensionPartTypeRelation
	exec (@tmpSQL)


	declare
		 @sql varchar(max)
		,@sqlAddColumnsToIntputTable varchar(max)
		,@sqlRelCPSelect varchar(max)
		,@sqlRelCPJoin varchar(max)
		,@sqlAttribSelect varchar(max)
		,@sqlAttribJoin varchar(max)
		,@sqlRelInsert varchar(max)
		,@sqlAttribInsert varchar(max)

		set @sql = null	
		set @sqlRelCPSelect = ''
		set @sqlRelCPJoin = ''
		set @sqlAttribSelect = ''
		set @sqlAttribJoin = ''
		set @sqlRelInsert = ''
		set @sqlAttribInsert = ''
		
		
			
		
		


	create table #InputTable
	(
		[Name] [nvarchar](100) NOT NULL,
		[Description] [varchar](200) NULL,
		[DisplayName] [nvarchar](150) NULL,
		[CreatedBy] [nvarchar](50) NULL,
		[CreatedDate] [datetime] NULL,
		[ModifiedBy] [nvarchar](50) NULL,
		[ModifiedDate] [datetime] NULL,
		[IsDeleted] [bit] NOT NULL
	)


	select
		@sqlAddColumnsToIntputTable = 'alter table #InputTable add ' + quotename(isnull(parsename(t.IDColumnName, 1), t.Name + 'ID')) + ' int' + @NewLine
	from
		app.DimensionPartType t
	where
		t.DimensionPartTypeID = @DimensionPartTypeID
		
	select
		@sqlAddColumnsToIntputTable = @sqlAddColumnsToIntputTable + 'alter table #InputTable add [Code] ' + 
			case 
				when t.DataTypeID = 'INT' then 'int'
				else 'nvarchar(50)'
			end + @NewLine
	from
		#SrcDimensionPartType t
	where
		t.ID = @SrcDimensionPartTypeID


	;with AllRelations(FromTypeID, ToTypeID, RelOrder) as
	(	
		select
			FromTypeID = r.DimensionPartTypeID
			,ToTypeID = r.IsPartOfDimensionPartTypeID
			,RelOrder = 1
		from
			#SrcDimensionPartTypeRelation r
		where
			r.DimensionPartTypeID = @SrcDimensionPartTypeID	
		union all
		select
			FromTypeID = r.DimensionPartTypeID
			,ToTypeID = r.IsPartOfDimensionPartTypeID
			,RelOrder = pr.RelOrder + 1
		from
			#SrcDimensionPartTypeRelation r
				inner join AllRelations pr on
					pr.ToTypeID = r.DimensionPartTypeID
	)
	,
	Relations(FromTypeID, ToTypeID, RelOrder, UseOne) as
	(
		select
			FromTypeID
			,ToTypeID
			,RelOrder
			,UseOne = dense_rank() over(partition by ToTypeID order by RelOrder)
		from
			AllRelations
	)
	select
		@sqlRelInsert = @sqlRelInsert + 
			'	,[' + isnull(parsename(targetT.IDColumnName, 1), targetT.Name + 'ID') + ']'
		,@sqlRelCPSelect = @sqlRelCPSelect + 
			'	,coalesce(cp' + cast(r.ToTypeID as varchar(12)) + '.ID, -' + cast(r.ToTypeID as varchar(12)) + ') as [' + coalesce(t.IDColumnName, 'CP' + cast(t.ID as varchar(99)) + 'ID') + ']' + @NewLine -- + 		
		,@sqlRelCPJoin = @sqlRelCPJoin +
			'		left join ' + @SourceDB + 'dbo.base_DimensionPartRelation r' + cast(r.ToTypeID as varchar(12)) + ' on' + @NewLine +
			'			r' + cast(r.ToTypeID as varchar(12)) + '.DimensionPartID = cp' + cast(r.FromTypeID as varchar(12)) + '.ID' + @NewLine +
			'			and r' + cast(r.ToTypeID as varchar(12)) + '.IsPartOfDimensionPartTypeID = ' + cast(r.ToTypeID as varchar(12)) + @NewLine +
			'		left join ' + @SourceDB + 'dbo.base_DimensionPart cp' + cast(r.ToTypeID as varchar(12)) + ' on' + @NewLine +
			'			cp' + cast(r.ToTypeID as varchar(12)) + '.ID = r' + cast(r.ToTypeID as varchar(12)) + '.IsPartOfDimensionPartID' + @NewLine
		,@sqlAddColumnsToIntputTable = @sqlAddColumnsToIntputTable + 'alter table #InputTable add [' + isnull(parsename(targetT.IDColumnName, 1), targetT.Name + 'ID') + '] int not null' + @NewLine
	from
		Relations r
			inner join #SrcDimensionPartType t on
				t.ID = r.ToTypeID
			inner join app.DimensionPartType targetT on
				targetT.Name = t.Name
	where
		r.UseOne = 1
	order by
		r.RelOrder
		

		
	select
		@sqlAttribInsert = @sqlAttribInsert + 
			'	,[' + at.Name + ']' + @NewLine
		,@sqlAttribSelect = @sqlAttribSelect + 
			'	,[' + at.Name + '] = a' + cast(at.ID as varchar(12)) + '.Data' + @NewLine
		,@sqlAttribJoin = @sqlAttribJoin + 
			'		left join ' + @SourceDB + 'dbo.base_DimensionPartAttribute a' + cast(at.ID as varchar(12)) + ' on' + @NewLine +
			'			a' + cast(at.ID as varchar(12)) + '.DimensionPartAttributeTypeID = ' + cast(at.ID as varchar(12)) + @NewLine +
			'			and a' + cast(at.ID as varchar(12)) + '.DimensionPartID = cp' + cast(@SrcDimensionPartTypeID as varchar(12)) + '.ID' + @NewLine
		,@sqlAddColumnsToIntputTable = @sqlAddColumnsToIntputTable + 'alter table #InputTable add [' + at.Name + '] nvarchar(250)' + @NewLine
	from
		#SrcDimensionPartTypeAttributeTypeRelation atr
			inner join #SrcDimensionPartAttributeType at on
				at.ID = atr.DimensionPartAttributeTypeID
	where
		atr.DimensionPartTypeID = @SrcDimensionPartTypeID
				
				
	select @sql = 		
		'insert into #InputTable(' + @NewLine +
		'	' + quotename(isnull(parsename(targetT.IDColumnName, 1), targetT.Name + 'ID')) + @NewLine +
		'	,IsDeleted' + @NewLine +
		'	,Code' + @NewLine +
		'	,Name' + @NewLine +
		'	,DisplayName' + @NewLine +
		'	,Description' + @NewLine +
		'	,CreatedBy' + @NewLine +
		'	,CreatedDate' + @NewLine +		
		'	,ModifiedBy' + @NewLine +
		'	,ModifiedDate' + @NewLine +		
			
		@sqlAttribInsert +
		@sqlRelInsert +
		')' + @NewLine +	
		'select' + @NewLine +
		'	' + quotename(isnull(parsename(targetT.IDColumnName, 1), targetT.Name + 'ID')) + ' = cp' + cast(t.ID as varchar(12)) + '.ID' + @NewLine +
		'	,isnull(cp' + cast(t.ID as varchar(12)) + '.IsDeleted, 0) as IsDeleted' + @NewLine +	
		case when t.DataTypeID = 'STR' then
		' 	,Code = case when cp' + cast(t.ID as varchar(12)) + '.ID <0 then null else cp' + cast(t.ID as varchar(12)) + '.CodeStrData end'  + @NewLine
		else
		'	,Code = case when cp' + cast(t.ID as varchar(12)) + '.ID <0 then null else cp' + cast(t.ID as varchar(12)) + '.CodeIntData end' + @NewLine
		end +
		'	,cp' + cast(t.ID as varchar(12)) + '.Name' + @NewLine +
		'	,cp' + cast(t.ID as varchar(12)) + '.DisplayName' + @NewLine +
		'	,cp' + cast(t.ID as varchar(12)) + '.Description' + @NewLine +
		'	,isnull(cp' + cast(t.ID as varchar(12)) + '.CreatedBy, suser_name()) as CreatedBy' + @NewLine +
		'	,isnull(cp' + cast(t.ID as varchar(12)) + '.CreatedDate, getdate()) as CreatedDate' + @NewLine +		
		'	,cp' + cast(t.ID as varchar(12)) + '.ModifiedBy as ModifiedBy' + @NewLine +
		'	,cp' + cast(t.ID as varchar(12)) + '.ModifiedDate as ModifiedDate' + @NewLine +		
			@sqlAttribSelect +
			@sqlRelCPSelect +
		'from' + @NewLine +
		'	' + @SourceDB + 'dbo.base_DimensionPart cp' + cast(t.ID as varchar(12)) + '' + @NewLine +
				@sqlAttribJoin +
				@sqlRelCPJoin +			
		'where' + @NewLine +
		'	cp' + cast(t.ID as varchar(12)) + '.DimensionPartTypeID = ' + cast(t.ID as varchar(12)) + @NewLine +
		'	and cp' + cast(t.ID as varchar(12)) + '.ID >= 0' + @NewLine +
		@NewLine 		
		--'exec app.AddNullDimensionPartMembers ' + cast(@DimensionPartTypeID as varchar(12))
	from
		#SrcDimensionPartType t
			inner join app.DimensionPartType targetT on
				targetT.DimensionPartTypeID = @DimensionPartTypeID
	where
		t.ID = @SrcDimensionPartTypeID

	drop table #SrcDimensionPartType	
	drop table #SrcDimensionPartAttributeType
	drop table #SrcDimensionPartTypeAttributeTypeRelation
	drop table #SrcDimensionPartTypeRelation

	if @TranCount = 0 begin tran
			
	exec (@sqlAddColumnsToIntputTable)
	exec (@SQL)

	declare @RowsAffected int
	
	exec @RowsAffected = app.SyncTable  
		@SourceTable = '#InputTable'
		,@TargetTable = @DimensionPartTable
		,@JoinColumns = null
		,@DeleteMode = null
		,@TargetFilter = @TargetFiler
		,@SupressWarnings = 1
		,@SynchronizedBy = @ChangesBy				
		,@Debug = @Debug
		
	if @AddNullMembers = 1
		begin 
			if isnull(@Debug, 0) = 0
				exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
					,@EventTitle = 'Add null members'					
					
			exec [app].[AddNullDimensionPartMembers]
				@DimensionPartTypeID = @DimensionPartTypeID
				,@Debug = @Debug
				
			if isnull(@Debug, 0) = 0		
				exec app.LogEventStop @EventIDStack = @EventIDStack out
		end
		

	if @TranCount = 0 commit tran
	
	drop table #InputTable	

	




	
	
	declare @EventDescription nvarchar(1000)
	select @EventDescription = 'Rows affected: ' + cast(@RowsAffected as varchar(12))

	if isnull(@Debug, 0) = 0		
		exec app.LogEventStop @EventIDStack = @EventIDStack out,
			@Description = @EventDescription
end try
begin catch	
	--
	-- Rollback transactions and log errors
	--	
	if @TranCount = 0 and @@trancount > 0 rollback tran
	
	exec app.HandleProcError @EventIDStack out, @ParentEventID, @ProcName
	exec app.ReThrowError
end catch
GO
