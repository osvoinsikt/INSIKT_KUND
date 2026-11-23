SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[DimEngine_HierarchyTableColumns]
(
	@HierarchyID int
	,@Target int
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
	declare @TableColumn table
	(
		ColumnIndex int not null identity(1,1)
		,Name sysname
		,ColType varchar(20) not null
		,LevelNr int
		,LevelName nvarchar(128)
		,DataTypeDef nvarchar(100) not null
		,Nullable bit null
		,TargetType int not null default(3) -- Bit1: DimensionTable, Bit2: TempDimensionTable
		,NullableInTemp bit null 
		,DefaultBinding nvarchar(100) null
	)

	if @Target is null or @Target not in (1,2)
		set @Target = 1
	


	declare @NrOfLevels int
	select @NrOfLevels = o.ValueInt from app.HierarchyOption o where o.HierarchyID = @HierarchyID and o.HierarchyOptionTypeID = 'LEVC'
	if @NrOfLevels is null 
		begin
			;with HierarchyNodeTable as
			(
				select
					LeafHierarchyNodeID
					,HierarchyNodeID
					,ParentHierarchyNodeID
					,LeafDistance
					,RootDistance = row_number() over (partition by LeafHierarchyNodeID order by LeafDistance desc) - 1
				from
					app.DimEngine_HierarchyLeafNodeTable(@HierarchyID)

			)
			select @NrOfLevels = max(RootDistance) + 1 from HierarchyNodeTable
		end

	;with 
	LevelNrTmp1 as (select 1 as Cnt union all select 1),				-- 2 rader
	LevelNrTmp2 as (select 1 as Cnt from LevelNrTmp1 a, LevelNrTmp1 b), -- 4 rader
	LevelNrTmp3 as (select 1 as Cnt from LevelNrTmp2 a, LevelNrTmp2 b), -- 16 rader
	LevelNrTmp4 as (select 1 as Cnt from LevelNrTmp3 a, LevelNrTmp3 b), -- 256 rader
	LevelNr as (select Nr = row_number() over (order by Cnt) from LevelNrTmp4) -- Tabell med columnen Nr med värdet 1 till 257
	,
	Levels as
	(
		select
			LevelNr = Nr - 1
		from
			LevelNr
		where
			Nr <= @NrOfLevels	
	)
	,
	PerLevelColumns as
	(
		select
			ColumnIndex = 1
			,Name = 'ID'
			,ColType = 'Level'		
			,DataTypeDef = 'int'
			,Nullable = 0
			,TargetType = 3
			,NullableInTemp = 1
		union all		
		select
			ColumnIndex = 2
			,Name = 'BinID'
			,ColType = 'Level'		
			,DataTypeDef = 'varbinary(128)'
			,Nullable = 0
			,TargetType = 2
			,NullableInTemp = 0
		union select
			ColumnIndex = 3
			,Name = 'NodeID'
			,ColType = 'Level'		
			,DataTypeDef = 'int'
			,Nullable = 1
			,TargetType = 2
			,NullableInTemp = 1
		union all
		select
			ColumnIndex = 4
			,Name = 'DisplayName'
			,ColType = 'Level'
			,DataTypeDef = 'nvarchar(500)'
			,Nullable = 1
			,TargetType = 3
			,NullableInTemp = 1
		union all
		select
			ColumnIndex = 5
			,Name = 'Sort'
			,ColType = 'Level'		
			,DataTypeDef = 'bigint'
			,Nullable = 0
			,TargetType = 3
			,NullableInTemp = 0
		union all
		select
			ColumnIndex = cast(5 + row_number() over (order by lt.Code) as int)
			,Name = 'DisplayName_' + lt.Code
			,ColType = 'Level'
			,DataTypeDef = 'nvarchar(500)'
			,Nullable = 1
			,TargetType = 3
			,NullableInTemp = 1 
		from
			app.HierarchyLanguage l
				inner join app.[Language] lt on
					lt.LanguageID = l.LanguageID
		where
			l.HierarchyID = @HierarchyID
			

	)
	insert into @TableColumn
	(
		Name
		,ColType
		,LevelNr
		,LevelName
		,DataTypeDef
		,Nullable
		,TargetType
		,NullableInTemp
	)
	select
		Name = 'L' + cast(l.LevelNr as varchar(12)) + '_' + lc.Name
		,ColType = lc.ColType		
		,LevelNr = l.LevelNr
		,LevelName = lc.Name
		,DataTypeDef = lc.DataTypeDef
		,Nullable = lc.Nullable
		,TargetType = lc.TargetType
		,NullableInTemp = lc.NullableInTemp
	from
		Levels l
			cross join PerLevelColumns lc
	order by
		l.LevelNr
		,lc.ColumnIndex



	insert into @TableColumn(Name,ColType,TargetType, DataTypeDef,Nullable)
	select
		Name = h.Name + '_LeafID'
		,ColType = 'LeafID'
		,TargetType = 1
		,DataTypeDef = 'int'
		,Nullable = 0		
	from
		app.Hierarchy h
	where
		h.HierarchyID = @HierarchyID
	union all
	select
		Name = h.Name + '_LeafID'
		,ColType = 'LeafID'
		,TargetType = 2
		,DataTypeDef = 'as L' + cast(@NrOfLevels - 1 as nvarchar(12)) + '_ID'
		,Nullable = null
	from
		app.Hierarchy h
	where
		h.HierarchyID = @HierarchyID


	insert into @TableColumn(Name,ColType,DataTypeDef)
	select
		Name = h.ColumnName
		,ColType = 'ExtraColumn'
		,DataTypeDef = DataType
	from
		app.HierarchyExtraColumn h
	where
		h.HierarchyID = @HierarchyID
		
		
	insert into @TableColumn(Name,ColType,DataTypeDef)
	select
		Name = h.Name
		,ColType = 'HierarchyAttribute'
		,DataTypeDef = 
			case h.DataTypeID
				when 'INT' then
					'int'
				when 'BIT' then
					'int'
				else
					'nvarchar(500)'
			end
	from
		app.HierarchyNodeAttributeType h
	where
		h.HierarchyID = @HierarchyID
		

		
	--insert into @TableColumn(Name,ColType,DataTypeDef, Nullable,NullableInTemp)
	--select distinct
	--	Name = dpk.ColumnName
	--	,ColType = 'KeyColumn'
	--	,DataTypeDef = 'int'
	--	,Nullable = 0
	--	,NullableInTemp = 1
	--from 
	--	app.HierarchyDimensionPartType  hdp
	--		inner join app.showDimensionPartTypeKeys dpk on
	--			dpk.DimensionPartTypeID = hdp.DimensionPartTypeID
	--where 
	--	hdp.HierarchyID = @HierarchyID
		
		
	;with 
	GrpRelatedDimensionPartType as
	(
		select distinct
			hdpGrpRel.DimensionPartTypeID
		from
			app.HierarchyDimensionPartType hdp
				inner join app.showDimensionPartTypeRelation grpRel on
					grpRel.DimensionPartTypeID = hdp.DimensionPartTypeID
					and grpRel.RelationTypeID = 'GRP'
				inner join app.HierarchyDimensionPartType hdpGrpRel on
					hdpGrpRel.DimensionPartTypeID = grpRel.ParentDimensionPartTypeID 
					and hdpGrpRel.HierarchyID = hdp.HierarchyID
		where
			hdp.HierarchyID = @HierarchyID
	)
	insert into @TableColumn(Name,ColType,DataTypeDef, Nullable,NullableInTemp)
	select
		Name = dpk.ColumnName
		,ColType = 
			case
				when sum(case when grpDp.DimensionPartTypeID is null then 1 else 0 end) > 0 then
					'KeyColumn'
				else
					'GrpKeyColumn'
			end
		,DataTypeDef = 'int'
		,Nullable = 0
		,NullableInTemp = 1
	from
		app.HierarchyDimensionPartType  dp
			left join GrpRelatedDimensionPartType grpDp on
				grpDp.DimensionPartTypeID = dp.DimensionPartTypeID
			inner join app.showDimensionPartTypeKeys dpk on
					dpk.DimensionPartTypeID = dp.DimensionPartTypeID
	where
		dp.HierarchyID = @HierarchyID
	group by
		dpk.ColumnName
		
		
	insert into @TableColumn(Name,ColType,DataTypeDef, Nullable, TargetType)
	values('LeafNodePriority','Prio', 'int', 0, 2)
		
	insert into @TableColumn(Name,ColType,DataTypeDef, Nullable, TargetType, DefaultBinding)
	values('CreatedBy','Audit', 'nvarchar(50)', 0, 1, 'suser_name()')
	insert into @TableColumn(Name,ColType,DataTypeDef, Nullable, TargetType, DefaultBinding)
	values('CreatedDate','Audit', 'DateTime', 0, 1, 'getdate()')
	insert into @TableColumn(Name,ColType,DataTypeDef, Nullable, TargetType)
	values('ModifiedBy','Audit', 'nvarchar(50)', 1, 1)
	insert into @TableColumn(Name,ColType,DataTypeDef, Nullable, TargetType)
	values('ModifiedDate','Audit', 'DateTime', 1, 1)
	


	insert into @Columns
	(
		ColumnIndex
		,Name
		,DataType
		,ColumnType
		,LevelNr
		,LevelName
		,DefaultBinding
	)
	select 
		ColumnIndex = row_number() over (order by c.ColumnIndex)
		,c.Name
		,DataType = 
			case case when @Target = 2 then isnull(c.NullableInTemp, c.Nullable) else c.Nullable end
				when 0 then c.DataTypeDef + ' not null'
				when 1 then c.DataTypeDef + ' null'
				else c.DataTypeDef
			end
		,c.ColType
		,LevelNr = c.LevelNr
		,LevelName = c.LevelName
		,DefaultBinding = c.DefaultBinding
	from 
		@TableColumn c
	where
		(c.TargetType  & @Target) > 0
	return;
end
GO
