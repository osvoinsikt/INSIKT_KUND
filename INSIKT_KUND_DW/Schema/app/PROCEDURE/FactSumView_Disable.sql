SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[FactSumView_Disable]
(
	@SourceFactTable nvarchar(512)
	,@Enable bit = 0
	,@Debug bit = 0
)
as
set @Enable = isnull(@Enable, 0)
begin try

	drop table if exists #SumIxViews
	;with ViewDepends as
	(
		select
			table_object_id = t.object_id
			,table_name = t.name
			,view_object_id = v.object_id
			,view_name = v.name
			,ObjectDef = OBJECT_DEFINITION(v.object_id)
			,CreateSumViewScript = 
				substring
				(
					OBJECT_DEFINITION(v.object_id)
					,nullif(patindex('%/*%', OBJECT_DEFINITION(v.object_id) ), 0) 
						+ 2
					,nullif(patindex('%*/%', OBJECT_DEFINITION(v.object_id) ), 0) 
						- nullif(patindex('%/*%', OBJECT_DEFINITION(v.object_id) ), 0) 
						- 4
				)
		from
			sys.tables t
				inner join sys.sql_expression_dependencies d on
					d.referenced_id = t.object_id
					and d.referenced_minor_id = 0
				inner join sys.views v on
					v.object_id = d.referencing_id
		where
			t.object_id = object_id(@SourceFactTable)
			and OBJECT_DEFINITION(v.object_id) like '%count_big(*)%'		
	)
	select
		Id = row_number() over (order by d.view_object_id)
		,d.*
	into #SumIxViews
	from
		ViewDepends d
	where
		d.CreateSumViewScript like '%FactSumView_Create%'
	
	if @@ROWCOUNT = 0
		raiserror('The table %s is not SumView-enabled (or has an invalid header-comment).
		To create SumView run: 
			exec app.FactSumView_Create ''%s''', 16, 10, @SourceFactTable, @SourceFactTable)

	
	declare 
		@CreateSumViewScript nvarchar(max)
		,@ViewName nvarchar(max)
		,@ViewIterator int = 1

	select
		@CreateSumViewScript = CreateSumViewScript 
		,@ViewName = view_name
	from 
		#SumIxViews 
	where 
		Id = @ViewIterator
	while @CreateSumViewScript <> ''
		begin
			select @CreateSumViewScript = 
				@CreateSumViewScript + '	' +
				iif
				(
					@Enable = 0
					,N',@CreateWithoutIndex = 1'
					,N',@CreateWithoutIndex = 0'
				)
			if @Debug = 1
				begin		
					print @CreateSumViewScript
			
				end
			else
				begin
					if @Enable = 1
						print 'Enable fact view for table ' + @SourceFactTable + ' (' + @ViewName + ')'
					else
						print 'Disable fact view for table ' + @SourceFactTable + ' (' + @ViewName + ')'
					exec (@CreateSumViewScript)
				end

			set @ViewIterator = @ViewIterator + 1
			set @CreateSumViewScript = null
			set @ViewName = null
			select
				@CreateSumViewScript = CreateSumViewScript 
				,@ViewName = view_name
			from 
				#SumIxViews 
			where 
				Id = @ViewIterator
		end
	
	
	
end try
begin catch
	throw;
end catch
GO
