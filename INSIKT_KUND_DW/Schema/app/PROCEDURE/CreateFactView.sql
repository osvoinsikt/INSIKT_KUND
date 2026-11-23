SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Author:		TRIMMA Affärsutveckling AB
-- Description:	Generate fact view with dimension part data.
---------------------------------------------------------------------------------------------
-- This will generate a view of fact tables information for related dimension parts.
-- Note:
-- Use app.CreateFactDimensionPartRelations to create forign keys and the performance of
-- views will increase.
-- ==========================================================================================
CREATE procedure app.CreateFactView
(
	@FactTable nvarchar(256)
	,@Debug bit = 0
)
as
if @Debug is null set @Debug = 0
--declare @FactTable nvarchar(256)
--set @FactTable = 'dbo.fact_HierarchyRelation_Resultatrapport_Bilbolaget'


declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount


declare @SQL nvarchar(max)

declare @NewLine char(2)
set @NewLine = char(13) + char(10)

if object_id(@FactTable) is null
	raiserror('Faktatabell %s hittades ej.', 16, 10, @FactTable)


begin try
	;with DPKeyCnt as
	(
		select
			dpKeys.DimensionPartTypeID
			,ColumnCnt = count(*)
		from
			app.showDimensionPartTypeKeys dpKeys
		group by
			dpKeys.DimensionPartTypeID
	)
	,
	DPRels as
	(
		select
			dpKeyCnt.DimensionPartTypeID
		from
			sys.columns factCols
				inner join app.showDimensionPartTypeKeys dpKeys on
					dpKeys.ColumnName = factCols.name
				inner join DPKeyCnt dpKeyCnt on
					dpKeyCnt.DimensionPartTypeID = dpKeys.DimensionPartTypeID
				
		where
			factCols.object_id = object_id(@FactTable)
		group by
			dpKeyCnt.DimensionPartTypeID
			,dpKeyCnt.ColumnCnt	
		having
			dpKeyCnt.ColumnCnt = count(*)
	)
	,
	SQLJoinData as
	(
		select
			--
			-- Sträng med kolumner som ska selekteras från dimensionsdelen.
			--
			DPSelColumnList =				
					(
						select
							'	,' + quotename(parsename(dpType.Name, 1) + '_' + c.name) + ' = ' + quotename(parsename(dpType.Name, 1)) + '.' + quotename(c.name) + @NewLine
						from
							sys.columns c
								left join sys.indexes pk on
									pk.object_id = c.object_id
									and pk.is_primary_key = 1
								left join sys.index_columns pkCol on
									pkCol.object_id = c.object_id
									and pkCol.column_id = c.column_id
									and pkCol.index_id = pk.index_id
						where
							c.object_id = object_id(app.GetDimensionPartTableName(dpType.DimensionPartTypeID))
							and pkCol.column_id is null
							and c.name not in
							(
								'CreatedBy'
								,'CreatedDate'
								,'ModifiedBy'
								,'ModifiedDate'
								
							)
						order by
							c.column_id
						for xml path(''), type
					).value('.', 'nvarchar(max)')					
			,DPJoin = '		inner join ' + app.GetDimensionPartTableName(dpType.DimensionPartTypeID) + ' ' + quotename(parsename(dpType.Name, 1)) + ' on'
			,DPJoinOn =			
					
					(
						select
							'			' + case when dpKeys.KeyNr = 1 then '' else 'and ' end +
							quotename(parsename(dpType.Name, 1)) + '.' + quotename(dpKeys.ColumnName) + ' = fact.' + quotename(dpKeys.ColumnName) + @NewLine
						from
							app.showDimensionPartTypeKeys dpKeys
						where
							dpKeys.DimensionPartTypeID = dpType.DimensionPartTypeID
						order by
							dpKeys.KeyNr
						for xml path(''), type
					).value('.', 'nvarchar(max)')
				,RelOrder = ROW_NUMBER() over (order by dpType.DimensionPartTypeID)
		from
			DPRels rel
				inner join app.DimensionPartType dpType on
					dpType.DimensionPartTypeID = rel.DimensionPartTypeID

	)
	select
		@SQL = 
			'select' + @NewLine +
			'	fact.*'+  @NewLine +
				(
					select
						DPSelColumnList
					from
						SQLJoinData
					order by
						RelOrder
					for xml path(''), type				
				).value('.','nvarchar(max)') +
			'from' + @NewLine +
			'	' + @FactTable + ' fact' + @NewLine +
				(
					select
						DPJoin + @NewLine +
						DPJoinOn
					from
						SQLJoinData
					order by
						RelOrder
					for xml path(''), type				
				).value('.','nvarchar(max)')
	from
		SQLJoinData
		
	--print @sql	


	declare @ViewName varchar(255)	
	select
		@ViewName = quotename(s.name) + '.' + quotename(o.name + 'View')
	from
		sys.objects o
			inner join sys.schemas s on
				s.schema_id = o.schema_id
	where
		o.object_id = object_id(@FactTable)
		
	if @Debug = 1
		exec app.PrintMax @SQL
	else
	begin
				
		begin tran
		if OBJECT_ID(@ViewName, 'v') is not null
			exec ('drop view ' + @ViewName)
		            
		exec
		(
			'create view ' + @ViewName + ' as' + @NewLine +
			@sql            
		)
		commit tran
		print 'View ' + @ViewName + ' created/updated.'
	end

end try
begin catch
	--
	-- Rollback transactions
	--
	if @TranCount = 0 and @@trancount > 0 rollback tran
	exec app.ReThrowError
end catch
GO
