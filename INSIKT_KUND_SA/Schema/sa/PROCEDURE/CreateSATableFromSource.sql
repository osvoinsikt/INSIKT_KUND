SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [sa].[CreateSATableFromSource] 
(
	@SourceTable nvarchar(256) -- Name and schema of source table.
	,@SourceColumns nvarchar(max) = null -- Null for all columns och comma separated list with columns to load (PK column are always loaded regardless if they are in the list or not).
	,@SA_SourceSystemID int = null -- SA_SourceSystem to use as source when reading source datatype and columns. When NULL the first with @TargetSchema
	,@TargetSchema nvarchar(256) = null
	,@TargetTable nvarchar(256) = null
	,@AddSaSourceSystemID bit = 0
	,@Debug bit = 0
)
as
set nocount on
begin try
	--quotename(@TargetSchema) + '.' + quotename(@TargetTable)


	declare
		@SourceLinkedServer nvarchar(256) = null	
		,@SourceDatabase nvarchar(256) = null

	declare @NewLine nchar(2)
	set @NewLine = nchar(13) + nchar(10)

	if @SA_SourceSystemID is null and @TargetSchema is not null
		begin
			select @SA_SourceSystemID = MIN(SA_SourceSystemID) from sa.base_SourceSystem where TargetSchema = @TargetSchema
		end

	if @SA_SourceSystemID is not null
		begin
			select
				@TargetSchema = s.TargetSchema
				,@SourceLinkedServer = s.LinkedServer
				,@SourceDatabase = s.[Database]
			from
				sa.base_SourceSystem s
			where
				s.SA_SourceSystemID = @SA_SourceSystemID
			if @@ROWCOUNT = 0
				raiserror('Unable to find SA_SourceSystemID %i.', 16, 10, @SA_SourceSystemID)
		end
	else
		raiserror('@SA_SourceSystemID cannot be null or no source system configured for target schema %s.', 16, 10, @TargetSchema)

	--declare @TargetTable nvarchar(128)
	if @TargetTable is null
		select @TargetTable = PARSENAME(@SourceTable, 1)
	
	declare @TargetTableFQN nvarchar(512)
	
	select
		@TargetTableFQN = 
			quotename(isnull(parsename(@TargetTable, 2), @TargetSchema))
			+ '.' + quotename(parsename(@TargetTable, 1))

	create table #SourceColumns
	(
		ColumnName varchar(512)  collate database_default not null
		,ColumnOrder int not null
		,SqlDataTypeExpression varchar(512) collate database_default not null
		,Nullable bit not null
		,Collation varchar(512) collate database_default
		,PrimaryKeyOrder int
	)
	exec [sa].[GetSourceTableInfo]
		@SourceTable = @SourceTable
		,@SourceColumns = @SourceColumns
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@RefreshSourceSystemColumns = 1

	if not exists(select 1 from #SourceColumns)
		raiserror('Table %s not found in source database.', 16,10, @SourceTable)

	declare @DynSQL nvarchar(max)
	select
		@DynSQL = 
		N'Create table ' + @TargetTableFQN + @NewLine
		+ N'(' + char(13) + char(10)
		+
		(
			select N'	' + case when row_number() over (order by col.ColumnOrder) = 1 then N'' else N',' end
				+ quotename(col.ColumnName) + N' ' + col.SqlDataTypeExpression
				+ case when col.Nullable = 0 then N' not null' else N'' end
				+ @NewLine
			from
				#SourceColumns col	
			order by
				col.ColumnOrder
			for xml path(''), type
		).value('.', 'nvarchar(max)')
		+ 
		case 
			when @AddSaSourceSystemID = 1 then 
				N'	,SA_SourceSystemID int not null' + @NewLine
			else
				N''
		end
		+
		isnull
		(
			N'	,' + @NewLine
			+ N'	constraint ' + quotename(N'PK_' + parsename(@TargetTableFQN, 2) + N'_' + parsename(@TargetTableFQN, 1)) + N' primary key' + @NewLine
			+ N'	(' + @NewLine
			+ 
			case 
				when @AddSaSourceSystemID = 1 then 
					N'		SA_SourceSystemID' + @NewLine	
				else
					N''
			end
			+
			(
				SELECT
					case
						when @AddSaSourceSystemID = 1 then
							N'		,'
						else
							N'		' + case when row_number() over (order by col.PrimaryKeyOrder) = 1  then N'' else N',' end
					end
					+ quotename(ColumnName) + @NewLine
				FROM
					#SourceColumns col
				where
					col.PrimaryKeyOrder is not null
				order by
					col.PrimaryKeyOrder
				for xml path(''), type
			).value('.', 'nvarchar(max)')
		
			+ N'	)' + @NewLine
			,
			N''	
		)
	
		+  N')'
	declare @CreateSchemaSQL nvarchar(max)
	if not exists(select 1 from sys.schemas where name = @TargetSchema)
		set @CreateSchemaSQL = 'create schema ' + QUOTENAME(@TargetSchema)

	if @DynSQL is null
		raiserror('Unexpected error: @DynSQL is null', 16, 10)

	if @Debug = 1 
		begin
			print '-- Query ---------------------------------------------------------------------------------------------'
			if @CreateSchemaSQL is not null exec app.PrintMax @CreateSchemaSQL
			exec app.PrintMax @DynSQL
			print '-------------------------------------------------------------------------------------------------------------'
			print ''
			print ''
		end
	

	if isnull(@Debug, 0) = 0
		begin
			if @CreateSchemaSQL is not null exec (@CreateSchemaSQL)
			exec (@DynSQL)

			set @DynSQL = N'Table ' + @TargetTableFQN + ' created.'
			print @DynSQL
		end
end try
begin catch
	exec app.ReThrowError
end catch
GO
