SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Author:		TRIMMA Affärsutveckling AB
-- Description:	Add dimension part and create dimension part type table
-- ==========================================================================================
CREATE procedure [app].[AddDimensionPartType]
(
	@Name varchar(100)
	,@Description nvarchar(500)
	,@CodeType varchar(100)
	,@AddNullMember bit = 0 /* Anger om ej satt medlem(ar) ska skapas */
	,@Relations varchar(1000) = null /* sträng med formatet KEY:1;GRP:2;... */
	,@Attributes nvarchar(4000) = null /* sträng med formatet Attributnamn1:Datatyp:Nullable(1/0):Defaultvärde;Attributnamn2:Datatyp:Nullable(1/0):Defaultvärde;... */
	,@IDColumnName varchar(100) = null
	,@DimensionPartTypeID int = null
	,@Debug bit = 0
) as
set nocount on;

declare @ProcName sysname, @TranCount int
set @ProcName = coalesce(object_name(@@procid), 'No procedure name available')
set @TranCount = @@TRANCOUNT

-- SET XACT_ABORT ON will cause the transaction to be uncommittable
-- when the constraint violation occurs and other runtime errors occure. 
set xact_abort on;

declare @NewLine char(2)
set @NewLine = CHAR(13) + CHAR(10)
begin try
	--declare @BaseSchemaName varchar(100)
	--set @BaseSchemaName = 'base'

	declare @TableName varchar(150)
	select
		@TableName = isnull(quotename('dw') + '.', '') + quotename('base_' + @Name)


	if @Name is null or LEN(@Name) = 0
		raiserror('Name cannot be empty', 16, 10)

	if exists(select 1 from app.DimensionPartType where Name = @Name)
		raiserror('Dimension part type %s already exists in table app.DimensionPartType', 16,10, @Name)
		
	if object_id(@TableName) is not null
		raiserror('Error adding dimension part type %s because table %s already exists.', 16,10, @Name, @TableName)	

	select @IDColumnName = ISNULL
							(
								quotename(parsename(@IDColumnName, 1))
								,quotename(@Name + 'ID')
							)
							
	if exists(select 1 from app.DimensionPartType where parsename(IDColumnName, 1) = PARSENAME(@IDColumnName, 1))
		raiserror('ID Column name %s must be unique. ', 16, 10, @IDColumnName)
		

	if @DimensionPartTypeID is null
			select @DimensionPartTypeID = isnull(max(DimensionPartTypeID), 0) + 1 from app.DimensionPartType
			
	if exists(select 1 from app.DimensionPartType where DimensionPartTypeID = @DimensionPartTypeID	)
		raiserror('DimensionPartTypeID = %i already exists.', 16, 10, @DimensionPartTypeID)
				

	create table #Columns
	(
		ID int not null identity(1,1)
		,Name sysname
		,IsPrimaryKey bit not null default(0)
		,DataType varchar(1000) not null
		,Nullable bit not null
		,DefaultValue nvarchar(1000)
		,IsIdentity bit not null default(0)
		,ColumnSource varchar(100) not null
	)


	insert into #Columns(Name, IsPrimaryKey, DataType, Nullable, IsIdentity, ColumnSource)
	values(@IDColumnName, 1, 'int', 0, 1, 'ID Column')


	create table #Relations
	(
		RelNr int not null 
		,RelationTypeID char(3) not null
		,ParentDimensionPartTypeID int not null primary key
	)

	;with RelationData as
	(
		select
			RelNr = rel.ListPos
			,RelDataID = relData.ListPos
			,relData = relData.Item
		from
			app.Split(@Relations, ';') rel
				cross apply app.Split(rel.Item, ':') relData
	)
	insert into #Relations
	(
		RelNr
		,RelationTypeID
		,ParentDimensionPartTypeID	
	)
	select
		data.RelNr
		,RelationTypeID = data.[1]
		,ParentDimensionPartTypeID = isnull(dpType.DimensionPartTypeID, cast(data.[2] as int))
	from
		RelationData
			pivot (
				min(relData)
				for RelDataID in ([1],[2])
			) data
			left join app.DimensionPartType dpType on
				dpType.Name = data.[2]


	create table #RelatedColumns 
	(
		DimensionPartTypeID int not null
		,ColumnName sysname
		,KeyNr int not null
		,LastKeyNr int not null		
	)
	insert into #RelatedColumns
	(
		DimensionPartTypeID
		,ColumnName
		,KeyNr
		,LastKeyNr		
	)
		
	select	
		k.DimensionPartTypeID
		,k.ColumnName
		,k.KeyNr
		,k.LastKeyNr
	from
		app.showDimensionPartTypeKeys k
			inner join #Relations r on
				r.ParentDimensionPartTypeID = k.DimensionPartTypeID

		
		
	insert into #Columns
	(
		Name
		,IsPrimaryKey
		,DataType
		,Nullable
		,ColumnSource
	)
	select	
		Name = quotename(k.ColumnName)
		,IsPrimaryKey = case when max(r.RelationTypeID) = 'KEY' then 1 else 0 end
		,DataType = 'int'
		,Nullable = 0
		,ColumnSource = 'Related ID Column'		
	from
		#RelatedColumns k
			inner join #Relations r on
				r.ParentDimensionPartTypeID = k.DimensionPartTypeID
	group by
		k.ColumnName
	


	insert into #Columns(Name,DataType,Nullable,ColumnSource)
	values (quotename('Code'), @CodeType, 1, 'Default attribute')

	insert into #Columns(Name,DataType,Nullable, ColumnSource)
	values (quotename('Name'), 'nvarchar(100)', 0, 'Default attribute')
	
	insert into #Columns(Name,DataType,Nullable, ColumnSource)
	values (quotename('DisplayName'), 'nvarchar(150)', 0, 'Default attribute')

	create table #Attributes
	(
		AttribNr int not null
		,AttributeName nvarchar(512)
		,AttributeDataType nvarchar(512)
		,AttributeNullable nvarchar(512)
		,AttributeDefaultVaule nvarchar(512)
	)
	;with AttributeData as
	(
		select 
			AttribNr = att.ListPos
			,AttributeDataID = attData.ListPos
			,AttributeData = attData.Item
		from
			app.SplitEscape(@Attributes, ';') att
				cross apply app.SplitEscape(att.Item, ':') attData
	)
	insert into #Attributes
	(
		AttribNr
		,AttributeName
		,AttributeDataType
		,AttributeNullable
		,AttributeDefaultVaule	
	)
	select
		AttribNr = data.AttribNr
		,AttributeName = quotename(nullif(parsename(data.[1], 1), ''))
		,AttributeDataType = nullif(data.[2], '')
		,AttributeNullable = nullif(data.[3], '')
		,AttributeDefaultVaule = nullif(data.[4], '')
	from
		AttributeData att
			pivot
			(
				min(AttributeData)
				for AttributeDataID in ([1],[2],[3],[4])
			) data

	if exists(
		select 1
		from
			#Attributes
		where
			AttributeName is null
			or AttributeNullable not in ('0', '1')
		)
			raiserror('Error parsing @Attributes parameter. @Attributes = ''%s''.', 16, 10, @Attributes) 
		
		
	insert into #Columns
	(
		Name
		,DataType
		,Nullable
		,DefaultValue
		,ColumnSource
	)
	select
		AttributeName
		,AttributeDataType
		,AttributeNullable
		,AttributeDefaultVaule
		,ColumnSource = 'Attribute'
	from
		#Attributes
	order by
		AttribNr





	insert into #Columns(Name,DataType,Nullable,DefaultValue, ColumnSource)
	values (quotename('CreatedBy'), 'nvarchar(50)', 0, 'suser_name()', 'Default attribute')
	insert into #Columns(Name,DataType,Nullable,DefaultValue, ColumnSource)
	values (quotename('CreatedDate'), 'datetime', 0, 'getdate()', 'Default attribute')

	insert into #Columns(Name,DataType,Nullable, ColumnSource)
	values (quotename('ModifiedBy'), 'nvarchar(50)', 1, 'Default attribute')
	insert into #Columns(Name,DataType,Nullable, ColumnSource)
	values (quotename('ModifiedDate'), 'datetime', 1, 'Default attribute')

	insert into #Columns(Name,DataType,Nullable,DefaultValue, ColumnSource)
	values (quotename('IsDeleted'), 'bit', 0, '0', 'Default attribute')

	declare @ErrorMsg nvarchar(max)
	select 
		@ErrorMsg = ISNULL(@ErrorMsg + @NewLine, '') +
			'Invalid datatype for ' + c.ColumnSource + ' ' + c.Name + '. DataType ' + isnull(c.DataType, '<NULL>') + ' does not exist.'
	from 
		#Columns c
			cross apply app.Split(c.DataType, '(') tParse
			left join sys.types t on
				t.name = parsename(tParse.Item, 1)
	where
		(tParse.ListPos is null or tParse.ListPos = 1)
		and t.system_type_id is null
		
	if @ErrorMsg is not null
		raiserror(@ErrorMsg, 16, 10)
		
		
	declare @SQL_Create nvarchar(max)
	declare @SQL_Unique nvarchar(max)

	select @SQL_Create = 
		'create table ' + @TableName + @NewLine + 
		'(' + @NewLine
		
		


	select
		@SQL_Create = @SQL_Create + '	' + case when ROW_NUMBER() over (order by c.ID) > 1 then ',' else '' end +
			c.Name + ' ' + c.DataType + 
				case when c.Nullable = 1 then ' null' else ' not null' end + 
				case when c.IsIdentity = 1 then ' identity(1,1)' else '' end +
				case when c.DefaultValue is not null then ' default(' + c.DefaultValue + ')' else '' end + @NewLine
	from
		#Columns c
	order by 
		c.ID
		
	select
		@SQL_Create = @SQL_Create + '	' + 
			case when ROW_NUMBER() over (order by c.ID) = 1 then 
				',constraint [PK_dw_base_' + @Name + '] primary key clustered' + @NewLine +
				'	(' + @NewLine +
				'		' 
			else 
				'	,' 
			end +
			c.Name + ' asc' + @NewLine
	from
		#Columns c
	where
		c.IsPrimaryKey = 1
	order by 
		c.ID
		
		
	select @SQL_Create = @SQL_Create + 
		'	)' + @NewLine + 
		')' + @NewLine
	
	select
		@SQL_Unique = 
			'create unique nonclustered index [IX_dw_base_' + @Name + '] on ' + @TableName + @NewLine +
			'(' + @NewLine +
			'	[Code]' + @NewLine
	select 			
		@SQL_Unique = @SQL_Unique +
			'	,' + c.Name
	from
		#Columns c
	where
		c.IsPrimaryKey = 1
		and c.ID > 1 -- Ta inte med egna ID-kolumnen
	
	select 			
		@SQL_Unique = @SQL_Unique +
			')' + @NewLine
	
	
	create table #SQL_FK
	(
		ParentDimensionPartTypeID int not null
		,SQL_FK nvarchar(max) not null
	)
	;with FKColumnListBuilder as
	(
		select
			DimensionPartTypeID = k.DimensionPartTypeID
			,KeyNr = k.KeyNr
			,LastKeyNr = k.LastKeyNr
			,ColumnList = cast(quotename(k.ColumnName) as nvarchar(max))
		from
			#RelatedColumns k
		where
			KeyNr = 1
		union all
		select
			DimensionPartTypeID = k.DimensionPartTypeID
			,KeyNr = k.KeyNr
			,LastKeyNr = k.LastKeyNr
			,ColumnList = cast(prevK.ColumnList + ', ' + quotename(k.ColumnName) as nvarchar(max))
		from
			FKColumnListBuilder prevK 
				inner join #RelatedColumns k on
					k.KeyNr = prevK.KeyNr + 1
					and k.DimensionPartTypeID = prevK.DimensionPartTypeID
		
	)
	insert into #SQL_FK
	(
		ParentDimensionPartTypeID
		,SQL_FK
	)
	select
		ParentDimensionPartTypeID = fkBuilder.DimensionPartTypeID
		,SQL_FK = 
			case parentObject.type
				when 'U' then
					'alter table ' + @TableName + ' with check add  constraint [FK_dw_base_' + @Name + '_' + parentType.Name + '] foreign key(' + fkBuilder.ColumnList + ')' + @NewLine +
					'references ' + app.GetDimensionPartTableName(parentType.DimensionPartTypeID) + ' (' + fkBuilder.ColumnList + ')' + @NewLine
				else
					'insert into app.DimensionPartTypeNonFKRelation(DimensionPartTypeID, ParentDimensionPartTypeID, DimensionPartTypeRelationTypeID)' + @NewLine + 
					'values(' + CAST(@DimensionPartTypeID as nvarchar(12)) + ',' + CAST(parentType.DimensionPartTypeID as nvarchar(12)) + ',''' + rel.RelationTypeID + ''')'
			end
	from
		FKColumnListBuilder fkBuilder
			inner join app.DimensionPartType parentType on
				parentType.DimensionPartTypeID = fkBuilder.DimensionPartTypeID
			inner join #Relations rel on
				rel.ParentDimensionPartTypeID = parentType.DimensionPartTypeID
			left join sys.objects parentObject on
				parentObject.object_id = object_id(parentType.TableName)
			
			
	where
		fkBuilder.LastKeyNr = 1
	
		
	if @TranCount = 0 begin tran
			
		if @Debug = 0
			begin
				exec (@SQL_Create)
				exec (@SQL_Unique)
			end
		else
			begin
				exec app.PrintMax @SQL_Create
				print 'GO'
				exec app.PrintMax @SQL_Unique
				print 'GO'
			end
			
		


		declare @ParentDimensionPartTypeID int
		select @ParentDimensionPartTypeID = min(ParentDimensionPartTypeID) from #SQL_FK
		while @ParentDimensionPartTypeID is not null
			begin
				select @SQL_Create = SQL_FK from #SQL_FK where ParentDimensionPartTypeID = @ParentDimensionPartTypeID
				if @Debug = 0
					exec (@SQL_Create)
				else
					begin						
						exec app.PrintMax @SQL_Create
						print 'GO'
					end
				
				select @ParentDimensionPartTypeID = min(ParentDimensionPartTypeID) from #SQL_FK where ParentDimensionPartTypeID > @ParentDimensionPartTypeID
			end
		

		

		if @Debug = 0	
			insert into app.DimensionPartType
			(
				DimensionPartTypeID
				,Name
				,Description
				,IDColumnName
				,AddNullMembers
			)
			values
			(
				@DimensionPartTypeID
				,@Name
				,@Description
				,@IDColumnName
				,@AddNullMember
			)
	if @TranCount = 0 commit tran
end try
begin catch
	--
	-- Rollback transactions
	--
	if @TranCount =0 and @@trancount > 0 rollback tran	
	exec app.ReThrowError
end catch
return @DimensionPartTypeID
GO
