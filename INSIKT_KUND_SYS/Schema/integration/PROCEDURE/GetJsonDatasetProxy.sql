SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [integration].[GetJsonDatasetProxy] 
(
	@DatasetName nvarchar(max)
)
as



--declare @TableName nvarchar(max) = 'KPIValue_Output'
declare @DynSQL nvarchar(max)



select
	@DynSQL = '
create function [insikt].[JsonTable_' + @DatasetName + ']
(
	@JsonData nvarchar(max)
)
returns table
return
	(
		select' 
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
				' +
							
				stuff
				(
					(
						select
							N',' +	quotename(c.ColumnName) + N' ' + c.DataType + N' ''' + c.JsonPath + '''
				'
						from
							integrationInternal.DatasetColumnView c
						where
							c.DatasetName = @DatasetName						
						order by
							c.ColumnOrder		
						for xml path, type
					).value(N'.[1]', N'nvarchar(max)')
					,1,1,''
				)
			 +

			N')
	);'
print @DynSQL


GO
