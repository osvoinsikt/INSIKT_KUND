SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[RestoreLoggedHierarchyConfiguration]
(
	@HierarchyID int
	,@LogID int	
	,@DoNotRestoreBinID bit = 0
) as
set nocount on

--
-- Save proceudre name and number of transactions to local variables @ProcName and @TranCount
-- The reason of @ProcName is to ease copy paste between procedures.
--
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount


begin try
	if @TranCount = 0 begin tran
	
	
	if not exists(select 1 HierarchyID from app.HierarchyLog where HierarchyLogID = @LogID and HierarchyID = @HierarchyID)
		raiserror('No hierarchy log with id %i exists for HierarchyID %i.', 16, 10, @LogId, @HierarchyID)
	

	select * into #HierarchyBinKeyLookup from app.[HierarchyBinKeyLookup] where HierarchyID = @HierarchyID
	
	delete from app.[HierarchyBinKeyLookup] where HierarchyID = @HierarchyID
	delete from app.[HierarchyNodeAttribute] where HierarchyNodeID in (select HierarchyNodeID from app.HierarchyNode where HierarchyID = @HierarchyID)
	delete from app.[HierarchyNodeAttributeType] where HierarchyID = @HierarchyID
	delete from app.[HierarchyExtraColumn] where HierarchyID = @HierarchyID
	delete from app.[HierarchyNodeLanguage] where HierarchyNodeID in (select HierarchyNodeID from app.HierarchyNode where HierarchyID = @HierarchyID)
	delete from app.[HierarchyNode] where HierarchyID = @HierarchyID
	delete from app.[HierarchyDimensionPartType] where HierarchyID = @HierarchyID
	delete from app.[HierarchyOption] where HierarchyID = @HierarchyID
	delete from app.[HierarchyLanguage] where HierarchyID = @HierarchyID
	
	
	select
		[HierarchyID]
		,[Name]
		,[Caption]
		,[Description]
	into #Hierarchy
	from
		app.[HierarchyLog]
	where
		[HierarchyLogID] = @LogID

	exec app.SyncTable
		@SourceTable = '#Hierarchy'
		,@TargetTable = 'app.Hierarchy'
		,@DeleteMode = 3 -- Inget tas bort, endast insert/update eller som i detta fall endast update

		
	insert into app.HierarchyLanguage
	(
		HierarchyID
		,LanguageID
		,Caption
	)
	select
		HierarchyID
		,LanguageID
		,Caption
	from
		app.HierarchyLanguageLog
	where
		[HierarchyLogID] = @LogID

	set identity_insert app.[HierarchyOption] on
	insert into app.[HierarchyOption]
	(
		[ID]
		,[HierarchyID]
		,[HierarchyOptionTypeID]
		,[ValueInt]
		,[ValueStr]
	)
	select
		[ID]
		,[HierarchyID]
		,[HierarchyOptionTypeID]
		,[ValueInt]
		,[ValueStr]
	from
		app.[HierarchyOptionLog]
	where
		[HierarchyLogID] = @LogID
	set identity_insert app.[HierarchyOption] off


	insert into app.[HierarchyDimensionPartType]
	(
		[HierarchyID]
		,[DimensionPartTypeID]
		,[DimensionPartFilterExpression]
		,[DefaultSortOrderExpression]
	)
	select
		[HierarchyID]
		,[DimensionPartTypeID]
		,[DimensionPartFilterExpression]
		,[DefaultSortOrderExpression]
	from
		app.[HierarchyDimensionPartTypeLog]
	where
		[HierarchyLogID] = @LogID

	set identity_insert app.[HierarchyNode] on
	insert into app.[HierarchyNode]
	(
		[HierarchyNodeID]
		,[HierarchyID]
		,[ParentHierarchyNodeID]
		,[SortOrder]
		,[DimensionPartTypeID]
		,[Priority]
		,[Expression]
		,[FilterExpression]
		,[SortOrderExpression]
		,[EmptyHeader]
	)
	select
		[HierarchyNodeID]
		,[HierarchyID]
		,[ParentHierarchyNodeID]
		,[SortOrder]
		,[DimensionPartTypeID]
		,[Priority]
		,[Expression]
		,[FilterExpression]
		,[SortOrderExpression]
		,[EmptyHeader]
	from
		app.[HierarchyNodeLog]
	where
		[HierarchyLogID] = @LogID
	set identity_insert app.[HierarchyNode] off

	insert into app.HierarchyNodeLanguage
	(
		HierarchyNodeID
		,LanguageID
		,LangExpression
	)
	select
		HierarchyNodeID
		,LanguageID
		,LangExpression
	from
		app.HierarchyNodeLanguageLog
	where
		[HierarchyLogID] = @LogID
		

	set identity_insert app.[HierarchyExtraColumn] on
	insert into app.[HierarchyExtraColumn]
	(
		[HierarchyExtraColumnID]
		,[HierarchyID]
		,[ColumnName]
		,[ValueExpression]
		,[DataType]
		,[DefaultEmptyValueExpression]
	)
	select
		[HierarchyExtraColumnID]
		,[HierarchyID]
		,[ColumnName]
		,[ValueExpression]
		,[DataType]
		,[DefaultEmptyValueExpression]
	from
		app.[HierarchyExtraColumnLog]
	where
		[HierarchyLogID] = @LogID
	set identity_insert app.[HierarchyExtraColumn] off

	set identity_insert app.[HierarchyNodeAttributeType] on
	insert into app.[HierarchyNodeAttributeType]
	(
		[HierarchyNodeAttributeTypeID]
		,[HierarchyID]
		,[Name]
		,[Description]
		,[DataTypeID]
	)
	select
		[HierarchyNodeAttributeTypeID]
		,[HierarchyID]
		,[Name]
		,[Description]
		,[DataTypeID]
	from
		app.[HierarchyNodeAttributeTypeLog]
	where
		[HierarchyLogID] = @LogID
	set identity_insert app.[HierarchyNodeAttributeType] off

	
	insert into app.[HierarchyNodeAttribute]
	(
		[HierarchyNodeID]
		,[HierarchyNodeAttributeTypeID]
		,[ValueInt]
		,[ValueStr]
	)
	select
		[HierarchyNodeID]
		,[HierarchyNodeAttributeTypeID]
		,[ValueInt]
		,[ValueStr]
	from
		app.[HierarchyNodeAttributeLog]
	where
		[HierarchyLogID] = @LogID
	


	set identity_insert app.[HierarchyBinKeyLookup] on
	if ISNULL(@DoNotRestoreBinID, 0) = 0
		begin
			insert into app.[HierarchyBinKeyLookup]
			(
				[HierarchyID]
				,[ID]
				,[BinID]
			)
			select
				[HierarchyID]
				,[ID]
				,[BinID]
			from
				app.[HierarchyBinKeyLookupLog]
			where
				[HierarchyLogID] = @LogID
		end
		
	insert into app.[HierarchyBinKeyLookup]
	(
		[HierarchyID]
		,[ID]
		,[BinID]
	)
	select
		[HierarchyID] = prevLookup.HierarchyID
		,[ID] = prevLookup.ID
		,[BinID] = prevLookup.BinID
	from
		#HierarchyBinKeyLookup prevLookup
			left join app.[HierarchyBinKeyLookup] newLookup on
				newLookup.ID = prevLookup.ID
				and newLookup.HierarchyID = prevLookup.HierarchyID
	where
		newLookup.ID is null
	
	
	set identity_insert app.[HierarchyBinKeyLookup] off


	drop table #HierarchyBinKeyLookup

	
	if @TranCount = 0 commit tran
end try
begin catch		
	if @TranCount = 0 and @@trancount > 0 rollback tran
	exec app.ReThrowError
end catch
GO
