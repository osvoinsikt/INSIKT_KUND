SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[DimEngine_CreateHierarchyTableConstraints]
(
	@HierarchyID int	
	,@TableName sysname
	,@Target int = 1	
	,@Debug bit = 0
)
as

declare @NewLine char(2)
set @NewLine = CHAR(13) + CHAR(10)

declare
	@Constraints nvarchar(max)
	,@TableDatabase nvarchar(128)

if left(parsename(@TableName, 1), 1) = '#'
	set @TableDatabase = 'tempdb'
else
	set @TableDatabase = parsename(@TableName, 3)
	


declare @PK_Name nvarchar(128) 
set @PK_Name = quotename('PK_' + replace(parsename(@TableName, 1), '#', ''))
exec app.GetUniqueObjectName @PK_Name output, @TableDatabase


select @Constraints = isnull(@Constraints, '') +
	'alter table ' + @TableName + ' add constraint ' + @PK_Name + ' primary key' + @NewLine +
	'	(' + @NewLine


	
select
	@Constraints = @Constraints + isnull('		' + case when row_number() over (order by c.Name) > 1 then ',' else '' end +
			quotename(c.Name) + @NewLine, '')
from
	app.DimEngine_HierarchyTableColumns(@HierarchyID, @Target) c
where
	c.ColumnType = 'KeyColumn'
order by 
	c.Name
	
--
-- I de fall som inga dimensionsdelar finns kopplade till hierarkin så kommer heller inte några naturliga nyckelkolumner att finnas
-- och i dessa fall så används LeafID-kolumnen som primärnyckel.
--
if @@ROWCOUNT = 0
	select
		@Constraints = @Constraints + '		' + case when row_number() over (order by c.ColumnIndex) > 1 then ',' else '' end +
				quotename(c.Name) + @NewLine
	from
		app.DimEngine_HierarchyTableColumns(@HierarchyID, @Target) c
	where
		c.ColumnType = 'LeafID'
	order by 
		c.ColumnIndex
	

select @Constraints = @Constraints +
	'	);' + @NewLine
	

declare @CreateFK bit

if exists(select 1 from app.HierarchyNode where HierarchyID = @HierarchyID and EmptyHeader = 1)
	set @CreateFK = 0
else
	set @CreateFK = 1

	
declare @FK_Name nvarchar(258)
declare @DimensionPartTypeID int
select @DimensionPartTypeID = min(DimensionPartTypeID) from app.HierarchyDimensionPartType where HierarchyID = @HierarchyID


if @CreateFK = 1
	begin
		--
		-- Detta är en fulfix för att kunna gå från en hierarki med empty headers till en utan.
		-- Fulfixen innebär att man egentligen bör aktivera två gånger för att konstraintet ska komma tillbaka.
		-- Hela den här tabellsynk-mekanismen borde skrivas om och flyttas till C#-kod. Detta är ett arv från den
		-- tidiga prototyp där procedur-generering helt låg i SQL.
		--
		declare @EmptyHeaderCheckSql nvarchar(max)
		select @EmptyHeaderCheckSql =
			'select top 1' + @NewLine +
			'	1 as Tst' + @NewLine +
			'from' + @NewLine +
			'	' + @TableName + @NewLine +
			'where'  + @NewLine +
			'	' + (select quotename(ColumnName) From app.showDimensionPartTypeKeys where DimensionPartTypeID = @DimensionPartTypeID and KeyNr = 1) +  ' < -1000'
		declare @Tst table (Tst int)
		insert into @Tst(Tst)
		exec (@EmptyHeaderCheckSql)


		
		if (exists(select 1 from @Tst))
			--
			-- Hierarkin har nu inte empty headers men data i hierarki-tabellen antyter att den vid förra aktivering hade det.		
			-- @CreateFK sätts då till 0 för att vi skulle få fel vid skapandet av constraintet. Förmodligen kommer vi att skapa
			-- FK:n vid nästa aktivering istället då vi synkat bort emptyheader-raden. Ordningen saker och ting görs är lite fucked up här...
			--		
			set @CreateFK = 0

	end

declare @DpIsTable bit

while @CreateFK = 1 and @DimensionPartTypeID is not null and @Target = 1 and isnull(@TableDatabase,'') <> 'tempdb'
	begin
		select
			@FK_Name = quotename('FK_' + replace(parsename(@TableName, 1), '#', '') + '_' + dpt.Name)
			,@DpIsTable = case when userTab.object_id is null then 0 else 1 end
		from
			app.DimensionPartType dpt
				left join sys.objects userTab on
					userTab.object_id = object_id(dpt.TableName)
					and userTab.type = 'U'
		where
			dpt.DimensionPartTypeID = @DimensionPartTypeID


		if @DpIsTable = 1
			begin			
				exec app.GetUniqueObjectName @FK_Name output, @TableDatabase
		
				select @Constraints = @Constraints +
					'alter table ' + @TableName + ' add constraint ' + @FK_Name + ' foreign key ' + @NewLine +
					'	(' + @NewLine
			
				select 
					@Constraints = @Constraints + '		' + case when c.KeyNr > 1 then ',' else '' end +
						quotename(c.ColumnName) + @NewLine
				from
					app.showDimensionPartTypeKeys c
				where
					c.DimensionPartTypeID = @DimensionPartTypeID
				order by 
					c.KeyNr
			
				select @Constraints = @Constraints +
					'	) references ' + app.GetDimensionPartTableName(@DimensionPartTypeID) + @NewLine +
					'	(' + @NewLine		
		
				select 
					@Constraints = @Constraints + '		' + case when c.KeyNr > 1 then ',' else '' end +
						quotename(c.ColumnName) + @NewLine
				from
					app.showDimensionPartTypeKeys c
				where
					c.DimensionPartTypeID = @DimensionPartTypeID
				order by 
					c.KeyNr
			
				select @Constraints = @Constraints +
					'	);' + @NewLine
			end
		select @DimensionPartTypeID = min(DimensionPartTypeID) from app.HierarchyDimensionPartType where HierarchyID = @HierarchyID and DimensionPartTypeID > @DimensionPartTypeID
	end
	

if @Debug = 0
	begin
		exec (@Constraints)
	end
else
	begin
		exec app.PrintMax @Constraints
	end
GO
