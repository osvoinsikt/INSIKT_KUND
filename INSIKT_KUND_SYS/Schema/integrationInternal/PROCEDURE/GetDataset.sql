SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [integrationInternal].[GetDataset]
(	
	@DatasetName varchar(128)
	,@JsonData nvarchar(max) output
	,@ReturnColumns nvarchar(max) = null
	,@DatasetFilter nvarchar(max) = null
)
as
declare
	@DynSQL nvarchar(max)
	,@DynSQLParam nvarchar(max)

declare
	@MissingColumns nvarchar(max)
	,@VerifiedReturnColumn nvarchar(max)
	,@DataTable nvarchar(max)


begin try

select 
	@DataTable =  DataTable
from
	integrationInternal.Dataset
where
	DataSetName = @DatasetName
if @@ROWCOUNT = 0
	raiserror('No dataset with name %s exists.', 16, 10, @DatasetName)

if @DataTable is null or len(@DataTable) = 0
	raiserror('No data table is specified for dataset %s.', 16, 10, @DatasetName)

if @ReturnColumns <> '' 
	begin
		
		;with ReturnColumns as
		(
			select
				ColumnName = parsename(ltrim(rtrim(retCol.strings)), 1)
			from
				[dbo].[sepstring](@ReturnColumns, ',') retCol	
		)
		select
			@VerifiedReturnColumn = 
				iif
				(
					dsCol.ColumnName is null
					,@VerifiedReturnColumn
					,isnull(@VerifiedReturnColumn + ', ', '') + QUOTENAME(dsCol.ColumnName)
				)
			,@MissingColumns = 
				iif
				(
					dsCol.ColumnName is null					
					,isnull(@MissingColumns + ', ', '') + QUOTENAME(retCol.ColumnName)
					,@MissingColumns
				)
		from
			ReturnColumns retCol
				left join integrationInternal.DatasetColumnView dsCol on
					dsCol.ColumnName = retCol.ColumnName
					and dsCol.DatasetName = @DatasetName
		
		if @MissingColumns is not null
			raiserror('@ReturnColumns contains columns that do not exist in the dataset %s. Columns missing: %s', 16, 10, @DatasetName, @MissingColumns)
	
		
	end
select
	@DynSQLParam = '@JsonData nvarchar(max) output'
	,@DynSQL = N'
select
	@JsonData = 
		(
			select
				' + isnull(@VerifiedReturnColumn, N'*') + N'
			from
				'  + @DataTable 
			+
			isnull
			(N'
			where
				' + @DatasetFilter
				,N''
				
			)
			+ '
			for json auto
		);'
exec sp_executesql @DynSQL, @DynSQLParam,  
	@JsonData = @JsonData output;	
end try
begin catch
throw;
end catch
GO
