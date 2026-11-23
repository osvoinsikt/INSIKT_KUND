SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [sa].[CreateSAViewWithLatestFilter] 
(
	@SATable nvarchar(256) -- Name of SA table (without schema).
	,@PartitionKeys nvarchar(256) -- Comma separated list of keys ("KDDEL, KOD")
	,@OrderByColumns nvarchar(256) --  Comma separated list columns to order the view rows ("TOMDATG")
	,@TargetSchema nvarchar(256)
	,@Debug bit = 0
)
as
set nocount on
begin try
	declare @ViewName nvarchar(128)
	select @ViewName = @SATable + '_latest'

	declare @DynSQL nvarchar(max)
	select
		@DynSQL = 
		'
		CREATE VIEW ' + quotename(@TargetSchema) + '.' + quotename(@ViewName) + ' AS
			with selectors as 
			(
				select            
					Selector = 
						row_number() over 
						(
							partition by 
								' + @PartitionKeys + '
							order by 
								' + @OrderByColumns + ' desc
						)            
					,*
				from 
					' + @TargetSchema + '.' + @SATable + '
			)

			select *
			from selectors
			where Selector = 1
		'

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
	

	if isnull(@Debug, 0) = 0 and OBJECT_ID(@TargetSchema + '.' + @ViewName, 'V') IS NULL
		begin
			if @CreateSchemaSQL is not null exec (@CreateSchemaSQL)
			exec (@DynSQL)

			set @DynSQL = N'View ' + quotename(@TargetSchema) + '.' + quotename(@ViewName) + ' created.'
			print @DynSQL
		end
end try
begin catch
	exec app.ReThrowError
end catch


GO
