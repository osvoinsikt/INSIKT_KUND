SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[CopyHierarchy]
(
	@SourceHierarchyID int
	,@TargetHierarchyID int
	,@TargetHierarchyName nvarchar(300) = null 
)
as
--declare
--	@SourceHierarchyID int = 25
--	,@TargetHierarchyID int = 28
--	,@TargetHierarchyName nvarchar(300) = null --'Testkopia'
set nocount on	
declare @TranCount int
select @TranCount = @@TRANCOUNT

begin try
	if @TranCount = 0 begin tran
	if not exists(select 1 from app.Hierarchy where HierarchyID = @SourceHierarchyID)
		raiserror('No hierarchy with HierarchID = %i exists.', 16, 10, @SourceHierarchyID)

	if @TargetHierarchyID is null 
		begin
			if @TargetHierarchyName is null or len(@TargetHierarchyName) = 0
				raiserror('@TargetHierarchyID and @TargetHierarchyName cannot be null', 16, 10)
				
			if exists(select 1 from app.Hierarchy where Name = @TargetHierarchyName)
				raiserror('An Hierarchy with the name %s already exists.', 16,10, @TargetHierarchyName)
			
			insert into app.Hierarchy
			(
				Name
				,Caption
				,Description
			)
			select
				Name = @TargetHierarchyName
				,Caption = @TargetHierarchyName
				,Description = 'Copy of ' + Name
			from
				app.Hierarchy
			where
				HierarchyID = @SourceHierarchyID
				
			set @TargetHierarchyID = SCOPE_IDENTITY()
		end
	else if not exists(select 1 from app.Hierarchy where HierarchyID = @TargetHierarchyID)
		begin
			if len(@TargetHierarchyName) = 0
				raiserror('@TargetHierarchyName cannot be null when copying to a new hierarchy.', 16, 10)
				
			if exists(select 1 from app.Hierarchy where Name = @TargetHierarchyName)
				raiserror('An Hierarchy with the name %s already exists.', 16,10, @TargetHierarchyName)
			
			set identity_insert app.Hierarchy on
			insert into app.Hierarchy
			(
				HierarchyID
				,Name
				,Caption
				,Description
			)
			select
				HierarchyID = @TargetHierarchyID
				,Name = @TargetHierarchyName
				,Caption = @TargetHierarchyName
				,Description = 'Copy of ' + Name				
			from
				app.Hierarchy
			where
				HierarchyID = @SourceHierarchyID
				
			set identity_insert app.Hierarchy off
		end


	--
	-- Ta bort befintlig konfiuration på måldimensionen
	--
	delete from app.HierarchyLanguage where HierarchyID = @TargetHierarchyID
	delete from app.HierarchyOption where HierarchyID = @TargetHierarchyID
	delete from app.HierarchyExtraColumn where HierarchyID = @TargetHierarchyID
	delete from app.HierarchyNodeAttribute where HierarchyNodeID in (select HierarchyNodeID  from app.HierarchyNode where HierarchyID = @TargetHierarchyID)
	delete from app.HierarchyNodeAttributeType where HierarchyID = @TargetHierarchyID
	delete from app.HierarchyNodeLanguage where HierarchyNodeID in (select HierarchyNodeID  from app.HierarchyNode where HierarchyID = @TargetHierarchyID)
	delete from app.HierarchyNode where HierarchyID = @TargetHierarchyID
	delete from app.HierarchyDimensionPartType where HierarchyID = @TargetHierarchyID
	
	


	--
	-- Kopiera hierarkikonfiguration från källhierarki
	--	
	insert into app.HierarchyDimensionPartType
	(
		HierarchyID
		,DimensionPartTypeID
		,DimensionPartFilterExpression
		,DefaultSortOrderExpression
	)
	select
		HierarchyID = @TargetHierarchyID
		,DimensionPartTypeID
		,DimensionPartFilterExpression
		,DefaultSortOrderExpression
	from
		app.HierarchyDimensionPartType
	where
		HierarchyID = @SourceHierarchyID
		

	
	insert into app.HierarchyOption
	(
		HierarchyID
		,HierarchyOptionTypeID
		,ValueInt
		,ValueStr
	)
	select
		HierarchyID = @TargetHierarchyID
		,HierarchyOptionTypeID
		,ValueInt
		,ValueStr
	from
		app.HierarchyOption
	where
		HierarchyID = @SourceHierarchyID
		
		
		

	
	insert into app.HierarchyExtraColumn
	(
		HierarchyID
		,ColumnName
		,ValueExpression
		,DataType
		,DefaultEmptyValueExpression
	)
	select
		HierarchyID = @TargetHierarchyID
		,ColumnName
		,ValueExpression
		,DataType
		,DefaultEmptyValueExpression
	from
		app.HierarchyExtraColumn
	where
		HierarchyID = @SourceHierarchyID

	insert into app.HierarchyLanguage
	(
		HierarchyID
		,LanguageID
		,Caption
	)
	select
		HierarchyID = @TargetHierarchyID
		,LanguageID
		,Caption = @TargetHierarchyName
	from
		app.HierarchyLanguage
	where
		HierarchyID = @SourceHierarchyID


	insert into app.HierarchyNodeAttributeType
	(
		HierarchyID
		,Name
		,Description
		,DataTypeID
	)
	select
		HierarchyID = @TargetHierarchyID
		,Name
		,Description
		,DataTypeID
	from
		app.HierarchyNodeAttributeType
	where
		HierarchyID = @SourceHierarchyID


	declare @ChildNodeID int
	select @ChildNodeID = min(s.HierarchyNodeID) from app.HierarchyNode s where s.HierarchyID = @SourceHierarchyID and s.ParentHierarchyNodeID is null
	while @ChildNodeID is not null
		begin
			exec app.CopyHierarchyNodeTree
				@SourceNodeID =@ChildNodeID
				,@TargetParentID = null
				,@TargetHierarchyID = @TargetHierarchyID
		
			select @ChildNodeID = min(s.HierarchyNodeID) from app.HierarchyNode s where s.HierarchyID = @SourceHierarchyID and s.ParentHierarchyNodeID is null and s.HierarchyNodeID > @ChildNodeID
		end

	if @TranCount = 0 commit tran

	
end try
begin catch
	if @TranCount = 0 and @@TRANCOUNT > 0 rollback tran
	exec app.PrintError
	exec app.ReThrowError
end catch
GO
