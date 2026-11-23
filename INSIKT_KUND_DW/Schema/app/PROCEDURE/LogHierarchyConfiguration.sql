SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[LogHierarchyConfiguration]
(
	@HierarchyID int
	,@LogDescription nvarchar(1000) = null
	,@ProcedureDefinition nvarchar(max) = null
	,@UserName varchar(128) = null
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
	declare @CurrentDatabaseVersoin varchar(20)
	select @CurrentDatabaseVersoin = v.[Version] from app.DatabaseVersion v where v.IsCurrent = 1
	declare @LogID int
	
	
	if @ProcedureDefinition is null
		select 
			@ProcedureDefinition = m.definition
		from
			sys.sql_modules m
		where
			m.object_id = object_id([app].[GetHierarchyLoadProcName](@HierarchyID))
			
	if @UserName is null or @UserName = ''
		select
			@UserName = suser_name()

	insert into app.HierarchyLogInfo(Description, EngineVersion, ProcDefinition, CreatedBy) values(@LogDescription, @CurrentDatabaseVersoin, @ProcedureDefinition, @UserName)
	select @LogID = scope_identity()
	

	insert into app.[HierarchyLog]
	(
		[HierarchyLogID]
		,[HierarchyID]
		,[Name]
		,[Caption]
		,[Description]
	)
	select
		[HierarchyLogID] = @LogID
		,[HierarchyID]
		,[Name]
		,[Caption]
		,[Description]
	from
		app.[Hierarchy]
	where
		HierarchyID = @HierarchyID


	insert into app.HierarchyLanguageLog
	(
		HierarchyLogID
		,HierarchyID
		,LanguageID
		,Caption
	)
	select
		HierarchyLogID = @LogID
		,HierarchyID
		,LanguageID
		,Caption
	from
		 app.HierarchyLanguage
	where
		HierarchyID = @HierarchyID
		
	insert into app.[HierarchyExtraColumnLog]
	(
		[HierarchyLogID]
		,[HierarchyExtraColumnID]
		,[HierarchyID]
		,[ColumnName]
		,[ValueExpression]
		,[DataType]
		,[DefaultEmptyValueExpression]
	)
	select
		[HierarchyLogID] = @LogID
		,[HierarchyExtraColumnID]
		,[HierarchyID]
		,[ColumnName]
		,[ValueExpression]
		,[DataType]
		,[DefaultEmptyValueExpression]
	from
		app.[HierarchyExtraColumn]
	where
		HierarchyID = @HierarchyID

	insert into app.[HierarchyDimensionPartTypeLog]
	(
		[HierarchyLogID]
		,[HierarchyID]
		,[DimensionPartTypeID]
		,[DimensionPartFilterExpression]
		,[DefaultSortOrderExpression]
	)
	select
		[HierarchyLogID] = @LogID
		,[HierarchyID]
		,[DimensionPartTypeID]
		,[DimensionPartFilterExpression]
		,[DefaultSortOrderExpression]
	from
		app.[HierarchyDimensionPartType]
	where
		HierarchyID = @HierarchyID

	insert into app.[HierarchyNodeLog]
	(
		[HierarchyLogID]
		,[HierarchyNodeID]
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
		[HierarchyLogID] = @LogID
		,[HierarchyNodeID]
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
		app.[HierarchyNode]
	where
		HierarchyID = @HierarchyID

	insert into app.HierarchyNodeLanguageLog
	(
		[HierarchyLogID]
		,[HierarchyNodeID]
		,[LanguageID]
		,[LangExpression]
	)
	select
		[HierarchyLogID] = @LogID
		,[HierarchyNodeID] = l.HierarchyNodeID
		,[LanguageID] = l.LanguageID
		,[LangExpression] = l.LangExpression
	from
		app.HierarchyNodeLanguage l
			inner join app.HierarchyNode n on
				n.HierarchyNodeID = l.HierarchyNodeID
	where
		n.HierarchyID = @HierarchyID

	insert into app.[HierarchyBinKeyLookupLog]
	(
		[HierarchyLogID]
		,[HierarchyID]
		,[ID]
		,[BinID]
	)
	select
		[HierarchyLogID] = @LogID
		,[HierarchyID]
		,[ID]
		,[BinID]
	from
		app.[HierarchyBinKeyLookup]
	where
		HierarchyID = @HierarchyID

	insert into app.[HierarchyOptionLog]
	(
		[HierarchyLogID]
		,[ID]
		,[HierarchyID]
		,[HierarchyOptionTypeID]
		,[ValueInt]
		,[ValueStr]
	)
	select
		[HierarchyLogID] = @LogID
		,[ID]
		,[HierarchyID]
		,[HierarchyOptionTypeID]
		,[ValueInt]
		,[ValueStr]
	from
		app.[HierarchyOption]
	where
		HierarchyID = @HierarchyID
	

	insert into app.[HierarchyNodeAttributeTypeLog]
	(
		[HierarchyLogID]
		,[HierarchyNodeAttributeTypeID]
		,[HierarchyID]
		,[Name]
		,[Description]
		,[DataTypeID]
	)
	select
		[HierarchyLogID] = @LogID
		,[HierarchyNodeAttributeTypeID]
		,[HierarchyID]
		,[Name]
		,[Description]
		,[DataTypeID]
	from
		app.[HierarchyNodeAttributeType]
	where
		HierarchyID = @HierarchyID

	insert into app.[HierarchyNodeAttributeLog]
	(
		[HierarchyLogID]
		,[HierarchyNodeID]
		,[HierarchyNodeAttributeTypeID]
		,[ValueInt]
		,[ValueStr]
	)
	select
		[HierarchyLogID] = @LogID
		,[HierarchyNodeID]
		,[HierarchyNodeAttributeTypeID]
		,[ValueInt]
		,[ValueStr]
	from
		app.[HierarchyNodeAttribute]
	where
		[HierarchyNodeID] in (select HierarchyNodeID from app.HierarchyNode where HierarchyID = @HierarchyID)

	--insert into app.[HierarchyNodeFilterLog]
	--(
	--	[HierarchyLogID]
	--	,[HierarchyNodeID]
	--	,[HierarchyNodeFilterID]
	--	,[ParentHierarchyNodeFilterID]
	--	,[FilterPosition]
	--	,[HierarchyNodeFilterTypeID]
	--	,[HierarchyNodeFilterOperatorID]
	--)
	--select
	--	[HierarchyLogID] = @LogID
	--	,[HierarchyNodeID]
	--	,[HierarchyNodeFilterID]
	--	,[ParentHierarchyNodeFilterID]
	--	,[FilterPosition]
	--	,[HierarchyNodeFilterTypeID]
	--	,[HierarchyNodeFilterOperatorID]
	--from
	--	app.[HierarchyNodeFilter]
	--where
	--	[HierarchyNodeID] = (select HierarchyNodeID from app.HierarchyNode where HierarchyID = @HierarchyID)
		
		
	--insert into app.[HierarchyNodeFilterCustomLog]
	--(
	--	[HierarchyLogID]
	--	,[HierarchyNodeFilterCustomID]
	--	,[HierarchyNodeFilterID]
	--	,[CustomSQL]
	--)
	--select
	--	[HierarchyLogID] = @LogID
	--	,[HierarchyNodeFilterCustomID]
	--	,[HierarchyNodeFilterID]
	--	,[CustomSQL]
	--from
	--	app.[HierarchyNodeFilterCustom]
	--where
	--	HierarchyNodeFilterID = (select nf.HierarchyNodeFilterID from app.HierarchyNode n inner join app.HierarchyNodeFilter nf on nf.HierarchyNodeID = n.HierarchyNodeID where HierarchyID = @HierarchyID)
		
		
	--insert into app.[HierarchyNodeFilterAttributeLog]
	--(
	--	[HierarchyLogID]
	--	,[HierarchyNodeFilterID]
	--	,[HierarchyNodeFilterAttributeID]
	--	,[DimensionPartTypeID]
	--	,[AttributeName]
	--)
	--select
	--	[HierarchyLogID] = @LogID
	--	,[HierarchyNodeFilterID]
	--	,[HierarchyNodeFilterAttributeID]
	--	,[DimensionPartTypeID]
	--	,[AttributeName]
	--from
	--	app.[HierarchyNodeFilterAttribute]
	--where
	--	HierarchyNodeFilterID = (select nf.HierarchyNodeFilterID from app.HierarchyNode n inner join app.HierarchyNodeFilter nf on nf.HierarchyNodeID = n.HierarchyNodeID where HierarchyID = @HierarchyID)


	--insert into app.[HierarchyNodeFilterAttributeValueLog]
	--(
	--	[HierarchyLogID]
	--	,[HierarchyNodeFilterAttributeValueID]
	--	,[HierarchyNodeFilterAttributeID]
	--	,[Value]
	--)
	--select
	--	[HierarchyLogID] = @LogID
	--	,[HierarchyNodeFilterAttributeValueID]
	--	,[HierarchyNodeFilterAttributeID]
	--	,[Value]
	--from
	--	app.[HierarchyNodeFilterAttributeValue]
	--where
	--	HierarchyNodeFilterAttributeID = (select nfa.HierarchyNodeFilterAttributeID from app.HierarchyNode n inner join app.HierarchyNodeFilter nf on nf.HierarchyNodeID = n.HierarchyNodeID inner join app.HierarchyNodeFilterAttribute nfa on nfa.HierarchyNodeFilterID = nf.HierarchyNodeFilterID where HierarchyID = @HierarchyID)
		
		
	--insert into app.[HierarchyNodeFilterAttributeIntervalLog]
	--(
	--	[HierarchyLogID]
	--	,[HierarchyNodeFilterAttributeIntervalID]
	--	,[HierarchyNodeFilterAttributeID]
	--	,[ValueStart]
	--	,[ValueStop]
	--)
	--select
	--	[HierarchyLogID] = @LogID
	--	,[HierarchyNodeFilterAttributeIntervalID]
	--	,[HierarchyNodeFilterAttributeID]
	--	,[ValueStart]
	--	,[ValueStop]
	--from
	--	app.[HierarchyNodeFilterAttributeInterval]
	--where
	--	HierarchyNodeFilterAttributeID = (select nfa.HierarchyNodeFilterAttributeID from app.HierarchyNode n inner join app.HierarchyNodeFilter nf on nf.HierarchyNodeID = n.HierarchyNodeID inner join app.HierarchyNodeFilterAttribute nfa on nfa.HierarchyNodeFilterID = nf.HierarchyNodeFilterID where HierarchyID = @HierarchyID)

	
	if @TranCount = 0 commit tran
end try
begin catch		
	if @TranCount = 0 and @@trancount > 0 rollback tran
	exec app.ReThrowError
end catch
GO
