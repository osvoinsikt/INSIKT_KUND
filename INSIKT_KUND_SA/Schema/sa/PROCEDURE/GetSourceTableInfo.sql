SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [sa].[GetSourceTableInfo] 
(
	@SourceTable nvarchar(256) -- Name and schema of source table.
	,@SourceColumns nvarchar(max) = null -- Null for all columns och comma separated list with columns to load (PK column are always loaded regardless if they are in the list or not).
	,@SA_SourceSystemID int = null -- SA_SourceSystem to use as source when reading source datatype and columns. When NULL the first with @TargetSchema
	,@AlwaysIncludePrimaryKeyColumns bit = 1
	,@RefreshSourceSystemColumns bit = 0
	,@SelectResult bit = null
)
as
set nocount on
	if @RefreshSourceSystemColumns is null set @RefreshSourceSystemColumns = 0

	if @SA_SourceSystemID is null
		raiserror ('@SA_SourceSystemID cannot be NULL', 16, 10)

	declare
		@SourceSystemProviderID int


	declare @SourceColumnTable table(ColumnName sysname)

	insert into @SourceColumnTable(ColumnName)
	select
		PARSENAME(cols.Item, 1)
	from
		app.Split(@SourceColumns, ',')  cols
	order by
		cols.ListPos

	if @RefreshSourceSystemColumns = 1
		delete from
			sa.SourceSystemColumns
		where
			SA_SourceSystemID = @SA_SourceSystemID
			and SourceTable = @SourceTable


	if object_id('tempdb..#SourceColumns') is null
		begin
			if @SelectResult is null set @SelectResult = 1
			create table #SourceColumns
			(
				ColumnName nvarchar(128)  collate database_default not null
				,ColumnOrder int not null
				,SqlDataTypeExpression varchar(512) collate database_default not null
				,Nullable bit not null
				,Collation varchar(512) collate database_default
				,PrimaryKeyOrder int
			)
		end
	
	
	insert into #SourceColumns
	(
		ColumnName
		,ColumnOrder
		,SqlDataTypeExpression
		,Nullable
		,Collation
		,PrimaryKeyOrder
	)
	select
		ColumnName
		,ColumnOrder
		,SqlDataTypeExpression
		,Nullable
		,Collation
		,PrimaryKeyOrder
	from
		sa.SourceSystemColumns
	where
		SA_SourceSystemID = @SA_SourceSystemID
		and SourceTable = @SourceTable
		and
		(
			@SourceColumns is null
			or 
			ColumnName in
			(
				select
					ColumnName
				from
					@SourceColumnTable
			)
			or (@AlwaysIncludePrimaryKeyColumns = 1 and PrimaryKeyOrder is not null)
		)

	if @@ROWCOUNT = 0 and not exists(select 1 from sa.SourceSystemColumns where	SA_SourceSystemID = @SA_SourceSystemID and SourceTable=@SourceTable)
		begin			
			--
			-- Inget cashat resultat hittades
			-- Hämta från källsystemsserver
			-- 
			select @SourceSystemProviderID = SourceSystemProviderID from sa.base_SourceSystem where SA_SourceSystemID = @SA_SourceSystemID
			if @@ROWCOUNT = 0
				raiserror('Unable to find SA_SourceSystemID %i.', 16, 10, @SA_SourceSystemID)


			--
			--
			-- SQL Server
			--	
			if @SourceSystemProviderID = 1
				insert into #SourceColumns
				(
					ColumnName
					,ColumnOrder
					,SqlDataTypeExpression
					,Nullable
					,Collation
					,PrimaryKeyOrder
				)
				exec sa.GetTableInfoFromSource_SQLServer
					@SourceTable = @SourceTable
					,@SourceColumns = null--@SourceColumns
					,@SA_SourceSystemID = @SA_SourceSystemID
	
			--
			-- Oracle
			--
			else if @SourceSystemProviderID = 2 -- Oracle
				insert into #SourceColumns
				(
					ColumnName
					,ColumnOrder
					,SqlDataTypeExpression
					,Nullable
					,Collation
					,PrimaryKeyOrder
				)
				exec sa.GetTableInfoFromSource_Oracle
					@SourceTable = @SourceTable
					,@SourceColumns = null --@SourceColumns
					,@SA_SourceSystemID = @SA_SourceSystemID

			--
			-- Unknown type
			--
			else
				raiserror('Unsupported SourceSystemProviderID %i for SA_SourceSystemID = %i', 16, 10, @SourceSystemProviderID, @SA_SourceSystemID)
			

			insert into sa.SourceSystemColumns
			(
				SA_SourceSystemID
				,SourceTable
				,ColumnName
				,ColumnOrder
				,SqlDataTypeExpression
				,Nullable
				,PrimaryKeyOrder
			)
			select
				SA_SourceSystemID = @SA_SourceSystemID
				,SourceTable = @SourceTable
				,ColumnName
				,ColumnOrder
				,SqlDataTypeExpression
				,Nullable
				,PrimaryKeyOrder
			from
				#SourceColumns

			if @SourceColumns is not null
				delete from 
					#SourceColumns
				where
					ColumnName not in
					(
						select
							ColumnName
						from
							@SourceColumnTable
					)
					and
					(
						PrimaryKeyOrder is null 
						or isnull(@AlwaysIncludePrimaryKeyColumns, 0) = 0
					)
		end
if @SelectResult = 1
	select
		ColumnName
		,ColumnOrder
		,SqlDataTypeExpression
		,Nullable
		,Collation
		,PrimaryKeyOrder
	from
		#SourceColumns
GO
