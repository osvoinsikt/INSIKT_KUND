SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[GetUniqueObjectName]
(	
	@ObjectName nvarchar(256) output
	,@ObjectDatabase nvarchar(128) = null
)
as
begin
	declare @DatabasePart nvarchar(128)
	set @DatabasePart = parsename(@ObjectName, 3)
	
	if @ObjectDatabase is null and left(parsename(@ObjectName, 1), 1) = '#' set @ObjectDatabase = 'tempdb'
	if @ObjectDatabase is null set @ObjectDatabase = @DatabasePart
		

	declare @ObjectSchema nvarchar(129)
	set @ObjectSchema = parsename(@ObjectName, 2)
	
	
	
	set @ObjectDatabase = isnull(@ObjectDatabase + '.', '')
	
	set @ObjectName = parsename(@ObjectName, 1)
	
	declare 	
		@sql nvarchar(2000)
		,@sqlParam nvarchar(1000)
	select 
		@sql = 
			'	
			select 
				@ObjectName = o.name + cast(max(isnull(cast(right(oo.name, len(oo.name) - len(@ObjectName)) as int), 0)) + 1 as varchar(12))	
			from
				' + @ObjectDatabase + 'sys.objects o
					inner join ' + @ObjectDatabase + 'sys.schemas s on
						s.schema_id = o.schema_id
					left join ' + @ObjectDatabase + 'sys.objects oo on 
						oo.name like @ObjectName + ''%''
						and oo.object_id <> o.object_id
						and isnumeric(right(oo.name, len(oo.name) - len(@ObjectName))) = 1
			where 
				o.name = @ObjectName
				and (s.name = @ObjectSchema or @ObjectSchema is null)
			group by
				o.name
			'
		,@sqlParam = '@ObjectName nvarchar(128) output, @ObjectSchema nvarchar(128)'
	
	execute sp_executesql @sql, @sqlParam,
                      @ObjectName = @ObjectName output
                      ,@ObjectSchema = @ObjectSchema;
                      
	set @ObjectName = isnull(quotename(@DatabasePart) + '.', '') + isnull(quotename(@ObjectSchema) + '.', '') + quotename(@ObjectName)
			
end
GO
