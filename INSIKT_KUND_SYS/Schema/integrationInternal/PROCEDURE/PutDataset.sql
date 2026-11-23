SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [integrationInternal].[PutDataset]
(
	@DatasetName varchar(128)
	,@JsonData nvarchar(max)	
	--
	-- JsonResult
	--	0	Success
	--	1	One or more rows with error
	--	10	Timeout (Check if INSIKT Service is running)
	--
	,@JsonResult nvarchar(max) = null output
	,@AsyncResult bit = 1	
)
as
declare @ReturnStatus int = 0 -- Success


declare 
	@AwaitCheckIntervalWaitTime char(11) = '00:00:00.500'
	,@AwaitTimeout char(11) = '00:01:00.000'

declare
	@DataTable nvarchar(max)
	,@PostPutOperation nvarchar(max)

select
	@DataTable = ds.DataTable
	,@PostPutOperation = isnull(ds.PostPutOperation, N'')
from
	integrationInternal.Dataset ds
where
	ds.DatasetName = @DatasetName



if @@ROWCOUNT = 0
	raiserror('No dataset with name %s exists.', 16, 10, @DatasetName)

if @DataTable is null or len(@DataTable) = 0
	raiserror('No data table is specified for dataset %s.', 16, 10, @DatasetName)

if @AsyncResult = 0 and not exists(select 1 from sys.columns where object_id = object_id(@DataTable) and name = 'IsProcessed')
	set @AsyncResult = 1
	

declare 
	@DynSQL nvarchar(max)
	,@DynSQL_Params nvarchar(max) = 
		N'@AwaitCheckIntervalWaitTime char(11)'
		+ N',@AwaitTimeout char(11)'
		+ N',@JsonData nvarchar(max)'
		+ N',@JsonResult nvarchar(max) output'
		+ N',@ReturnStatus int output'

select
	@DynSQL = 
N'
declare @PutPK table
(
' 
+ 
(
	select
		N'	' + iif(row_number() over (order by c.ColumnOrder) > 1, N',', N'') + QUOTENAME(c.ColumnName) + N' ' + c.DataType + N' not null'
	from
		integrationInternal.DatasetColumnView c
	where
		c.DatasetName = @DatasetName
		and c.IsTablePrimaryKey = 1
	order by
		c.ColumnOrder
FOR XML PATH, TYPE
).value(N'.[1]', N'nvarchar(max)')
+
N'
)
insert into ' + @DataTable + N'
(' 
+ 
(
	select N'
	' + iif(row_number() over (order by c.ColumnOrder) > 1, N',', N'') + QUOTENAME(c.ColumnName)
	from
		integrationInternal.DatasetColumnView c
	where
		c.DatasetName = @DatasetName
		and c.IsWritable = 1
	order by
		c.ColumnOrder
FOR XML PATH, TYPE
).value(N'.[1]', N'nvarchar(max)')
+
N'
)
output 
' 
+ 
(
	select N'
	' + iif(row_number() over (order by c.ColumnOrder) > 1, N',', N'') + N'inserted.' + QUOTENAME(c.ColumnName)
	from
		integrationInternal.DatasetColumnView c
	where
		c.DatasetName = @DatasetName
		and c.IsTablePrimaryKey = 1
	order by
		c.ColumnOrder
FOR XML PATH, TYPE
).value(N'.[1]', N'nvarchar(max)')
+
N'
into 
	@PutPK
select
' 
+ 
(
	select N'
	' + iif(row_number() over (order by c.ColumnOrder) > 1, N',', N'') + QUOTENAME(c.ColumnName) 
		+ N' = ' 
			+ 
			ISNULL
			(
				N'isnull(' + QUOTENAME(c.ColumnName) + N', ' + c.DefaultValue + N')'
				, QUOTENAME(c.ColumnName) 
			)
	from
		integrationInternal.DatasetColumnView c
	where
		c.DatasetName = @DatasetName
		and c.IsWritable = 1
	order by
		c.ColumnOrder
FOR XML PATH, TYPE
).value(N'.[1]', N'nvarchar(max)')
+
N'
from
	OpenJson(@JsonData) 
	with 
	(
	' 
	+ 
	(
		select N'
		' + iif(row_number() over (order by c.ColumnOrder) > 1, N',', N'') 
			+ QUOTENAME(c.ColumnName) + N' ' + c.DataType + N' ''' + replace(c.JsonPath, '''', '''''') + ''''
		from
			integrationInternal.DatasetColumnView c
		where
			c.DatasetName = @DatasetName
			and c.IsWritable = 1
		order by
			c.ColumnOrder
	FOR XML PATH, TYPE
	).value(N'.[1]', N'nvarchar(max)')
	+ 
	N'
	)


' + @PostPutOperation + N'

'
+
iif( @AsyncResult = 0, N'
			
        declare @StartTime datetime = getutcdate()
        declare @TimeoutAt datetime = @StartTime + @AwaitTimeout

		while
        (
            exists
            (
                select top 1
                    DoWait = 1
                from
					@PutPK res
						inner join ' + @DataTable + N' input on' 
						+ 
						(
							select N'
							' + iif(row_number() over (order by c.ColumnOrder) > 1, N'and ', N'') 
								+ N'input.' + QUOTENAME(c.ColumnName) + N' = res.' + QUOTENAME(c.ColumnName)
							from
								integrationInternal.DatasetColumnView c
							where
								c.DatasetName = @DatasetName
								and c.IsTablePrimaryKey = 1
							order by
								c.ColumnOrder
						FOR XML PATH, TYPE
						).value(N'.[1]', N'nvarchar(max)')
						+ 
						N'
                where
                    input.IsProcessed = 0
            )
            and
            (
                getutcdate() < @TimeoutAt
            )
        )
            begin
                waitfor delay @AwaitCheckIntervalWaitTime               
            end

		declare 
			@AllIsProcessed bit = 0
			,@WithErrors bit = 0

		select
			@AllIsProcessed = min(cast(input.IsProcessed as smallint))
			,@WithErrors = max(cast(input.ErrorOccured as smallint))
        from
			@PutPK res
				inner join ' + @DataTable + N' input on' 
				+ 
				(
					select N'
					' + iif(row_number() over (order by c.ColumnOrder) > 1, N'and ', N'') 
						+ N'input.' + QUOTENAME(c.ColumnName) + N' = res.' + QUOTENAME(c.ColumnName)
					from
						integrationInternal.DatasetColumnView c
					where
						c.DatasetName = @DatasetName
						and c.IsTablePrimaryKey = 1
					order by
						c.ColumnOrder
				FOR XML PATH, TYPE
				).value(N'.[1]', N'nvarchar(max)')
				+ 
				N'
                    

		if @AllIsProcessed = 0
			set @ReturnStatus = 10 -- Timeout error
		else if @WithErrors = 1
			set @ReturnStatus = 1 -- One or more rows with error

	'
	,N''
)
+
N'
select
	@JsonResult =
		(
			select' 
			+ 
			(
				select N'
				' + iif(row_number() over (order by c.ColumnOrder) > 1, N',', N'') 
					+ QUOTENAME(c.ColumnName) + N' = input.' + QUOTENAME(c.ColumnName)
				from
					integrationInternal.DatasetColumnView c
				where
					c.DatasetName = @DatasetName
					and 
					(
						c.IsTablePrimaryKey = 1
						or c.IsDatasetPrimaryKey = 1
						or c.IsInsiktStatusColumn = 1
					)
				order by
					c.ColumnOrder
			FOR XML PATH, TYPE
			).value(N'.[1]', N'nvarchar(max)')
			+ 
			N'
			from
				@PutPK res
					inner join ' + @DataTable + N' input on' 
					+ 
					(
						select N'
						' + iif(row_number() over (order by c.ColumnOrder) > 1, N'and ', N'') 
							+ N'input.' + QUOTENAME(c.ColumnName) + N' = res.' + QUOTENAME(c.ColumnName)
						from
							integrationInternal.DatasetColumnView c
						where
							c.DatasetName = @DatasetName
							and c.IsTablePrimaryKey = 1
						order by
							c.ColumnOrder
					FOR XML PATH, TYPE
					).value(N'.[1]', N'nvarchar(max)')
					+ 
					N'
			for json auto
		);
	'


exec sp_executesql
	@DynSQL
	,@DynSQL_Params
	,@AwaitCheckIntervalWaitTime
	,@AwaitTimeout
	,@JsonData
	,@JsonResult output
	,@ReturnStatus output



return @ReturnStatus;
GO
