SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure app.Support_AlterObject_AddSnippet
(
	@AlterObject nvarchar(max)
	,@SnippetDescription nvarchar(max)
	,@Snippet nvarchar(max)
	,@InsertSnippetAtRowWithPattern nvarchar(max)
	,@ReversePatternSearch bit = 1	
	,@AlterConditionPattern nvarchar(max) = null
	,@Debug bit = 0
)
as

--
-- Standardvariabler
--
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount



begin try
	-----------

declare @CreateScript nvarchar(max), @DropScript nvarchar(max)
declare @InsertSnippetAtIndex int


select
	@CreateScript = OBJECT_DEFINITION(OBJECT_ID(@AlterObject))
	if @CreateScript is null
		raiserror('Hittade inte någon källkod till object %s.', 16, 10, @AlterObject)

if @CreateScript not like @AlterConditionPattern or  @AlterConditionPattern is null
	begin
		if not @Debug = 1 raiserror ('Uppdaterar %s: %s', 0, 0, @AlterObject, @SnippetDescription) with nowait
		if @ReversePatternSearch = 1
			begin
				select @InsertSnippetAtIndex = PATINDEX(reverse(@InsertSnippetAtRowWithPattern), reverse(@CreateScript))
				if @InsertSnippetAtIndex > 0 select @InsertSnippetAtIndex = LEN(@CreateScript) - @InsertSnippetAtIndex + 1
			end
		else
			begin
				select @InsertSnippetAtIndex = PATINDEX(@InsertSnippetAtRowWithPattern, @CreateScript)
			end
			
		if @InsertSnippetAtIndex = 0
			raiserror('Hittade inte någont bra ställe att infoga ändring i %s på.
Proceduren måste uppdateras manuellt.', 16, 10, @AlterObject)

		


		select	
			@InsertSnippetAtIndex = @InsertSnippetAtIndex - charindex(char(13), reverse(left(@CreateScript, @InsertSnippetAtIndex)))
	
		select @CreateScript = 
			LEFT(@CreateScript, @InsertSnippetAtIndex) 
			+ @Snippet
			+ RIGHT(@CreateScript, LEN(@CreateScript) - @InsertSnippetAtIndex)
	
		select
			@DropScript = N'drop ' + 
				case o.[type]
					when 'P' then N'procedure'
					when 'V' then N'view'
					when 'TF' then N'function'
					when 'FN' then N'function'
					when 'IF' then N'function'
				end	+
				' ' + @AlterObject
		from
			sys.objects o
		where
			o.object_id = object_id(@AlterObject)
		if @Debug = 1
			begin
				exec app.PrintMax @DropScript
				exec app.PrintMax 'go'
				exec app.PrintMax @CreateScript
				exec app.PrintMax 'go'
			end
		else
			begin
				if @TranCount = 0 begin tran;
				exec (@DropScript)		
				exec (@CreateScript)
				if @TranCount = 0 commit tran;
			end
		
	end


end try
begin catch	
	--
	-- Roll back any transactions and log errors
	--
	if @TranCount = 0 and @@trancount > 0 rollback tran;
	throw;
end catch
GO
