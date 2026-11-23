SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [integration].[GetDatasetCreateTableScript] 
(
	@DatasetName nvarchar(max)
)
as

declare @DynSQL nvarchar(max)


select
	@DynSQL = '
create table [insikt].[' + @DatasetName + ']
(
	' +
							
				stuff
				(
					(
						select
							N',' +	quotename(c.ColumnName) + N' ' + c.DataType + N' ' + iif(c.IsNullable = 0, N'not ', N'') + N'null
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
			N');
'
declare 
	@HasDatasetPrimaryKey bit
	,@HasTablePrimaryKey bit
	,@DatasetKeyAsPK bit

select
	@HasDatasetPrimaryKey = 
		iif
		(
			--
			-- Har en eller fler nycklar satt
			-- 
			sum(cast(c.IsDatasetPrimaryKey as int)) > 0

			, 1, 0
		)
	,@HasTablePrimaryKey = 
		iif
		(
			sum(cast(c.IsTablePrimaryKey as int)) > 0
			--
			-- Och inte är identisk som tabellen PK
			--
			and not
			(
				sum(iif(c.IsDatasetPrimaryKey = 1 and c.IsTablePrimaryKey = 1, 1, 0)) = sum(cast(c.IsDatasetPrimaryKey as int))
				and sum(cast(c.IsDatasetPrimaryKey as int)) = sum(cast(c.IsTablePrimaryKey as int))
			)

			, 1, 0
		)
	,@DatasetKeyAsPK = 
		iif
		(
			sum(cast(c.IsDatasetPrimaryKey as int)) > 0
			and sum(iif(c.IsDatasetPrimaryKey = 1 and c.IsNullable = 1, 1, 0)) = 0
			,1
			,0
		)
from
	integrationInternal.DatasetColumnView c
where
	c.DatasetName = @DatasetName
--select
--	@HasDatasetPrimaryKey 
--	,@HasTablePrimaryKey 
--	,@DatasetKeyAsPK

if @DatasetKeyAsPK = 1
	begin
		select @DynSQL = @DynSQL + N'
ALTER TABLE [insikt].[' + @DatasetName + '] ADD  CONSTRAINT [PK_insikt_' + @DatasetName + '] PRIMARY KEY CLUSTERED 
(
	' +
							
		stuff
		(
			(
				select
					N',' +	quotename(c.ColumnName) +N'
	'
				from
					integrationInternal.DatasetColumnView c
				where
					c.DatasetName = @DatasetName
					and c.IsDatasetPrimaryKey = 1
				order by
					c.ColumnOrder		
				for xml path, type
			).value(N'.[1]', N'nvarchar(max)')
			,1,1,''
		)
		+
			N');'
	end
else
	begin
		if @HasTablePrimaryKey = 1
			begin
				select @DynSQL = @DynSQL + N'
ALTER TABLE [insikt].[' + @DatasetName + '] ADD  CONSTRAINT [PK_insikt_' + @DatasetName + '] PRIMARY KEY '  +
					iif(@HasDatasetPrimaryKey = 1, N'NONCLUSTERED', N'CLUSTERED') + 
N' 
(
	' +
							
		stuff
		(
			(
				select
					N',' +	quotename(c.ColumnName) +N'
	'
				from
					integrationInternal.DatasetColumnView c
				where
					c.DatasetName = @DatasetName
					and c.IsTablePrimaryKey = 1
				order by
					c.ColumnOrder		
				for xml path, type
			).value(N'.[1]', N'nvarchar(max)')
			,1,1,''
		)
		+
			N');'
			end


		if @HasDatasetPrimaryKey = 1
			begin
				select @DynSQL = @DynSQL + N'
CREATE UNIQUE CLUSTERED INDEX [IX_insikt_' + @DatasetName + '] ON [insikt].[' + @DatasetName + ']
(
	' +
							
		stuff
		(
			(
				select
					N',' +	quotename(c.ColumnName) +N'
	'
				from
					integrationInternal.DatasetColumnView c
				where
					c.DatasetName = @DatasetName
					and c.IsDatasetPrimaryKey = 1
				order by
					c.ColumnOrder		
				for xml path, type
			).value(N'.[1]', N'nvarchar(max)')
			,1,1,''
		)
		+
			N');'
			end
	end

/*

*/
print @DynSQL

GO
