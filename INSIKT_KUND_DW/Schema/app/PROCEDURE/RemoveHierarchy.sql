SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[RemoveHierarchy]
(
	@HierarchyID int
)
as
declare @TranCount int

set @TranCount = @@trancount

begin try
	if not exists(select 1 from app.Hierarchy where HierarchyID = @HierarchyID)
		raiserror('Hierarki med HierarchyID %i finns inte.', 16, 10, @HierarchyID)
	else
		begin
				
			if @TranCount = 0 begin tran
				declare @DynSQL nvarchar(max)


				if object_id(app.GetHierarchyLoadProcName(@HierarchyID)) is not null
					begin
						select @DynSQL = 'drop procedure ' + app.GetHierarchyLoadProcName(@HierarchyID)
						exec (@DynSQL)
					end

				if object_id(left( [app].[GetHierarchyTableName](@HierarchyID), len([app].[GetHierarchyTableName](@HierarchyID)) - 1) + '_ParentChild]') is not null
					begin
						select @DynSQL = 'drop view ' + left( [app].[GetHierarchyTableName](@HierarchyID), len([app].[GetHierarchyTableName](@HierarchyID)) - 1) + '_ParentChild]'
						exec (@DynSQL)
					end

				delete from app.RoleTaskRelation where HierarchyID = @HierarchyID

				delete from app.HierarchyNodeAttribute where HierarchyNodeID in (select HierarchyNodeID from app.HierarchyNode where HierarchyID = @HierarchyID)
				delete from app.HierarchyNodeAttributeLog where HierarchyNodeID in (select HierarchyNodeID from app.HierarchyNodeLog where HierarchyID = @HierarchyID)


				delete from app.HierarchyNodeAttributeType where HierarchyID = @HierarchyID
				delete from app.HierarchyNodeAttributeTypeLog where HierarchyID = @HierarchyID


				delete from app.HierarchyOption where HierarchyID = @HierarchyID
				delete from app.HierarchyOptionLog where HierarchyID = @HierarchyID

				delete from app.HierarchyNode where HierarchYID = @HierarchyID
				delete from app.HierarchyNodeLog where HierarchYID = @HierarchyID

				delete from app.HierarchyDimensionPartType where HierarchyID = @HierarchyID
				delete from app.HierarchyDimensionPartTypeLog where HierarchyID = @HierarchyID
				delete from app.HierarchyExtraColumn where HierarchyID = @HierarchyID
				delete from app.HierarchyExtraColumnLog where HierarchyID = @HierarchyID

				delete from app.HierarchyBinKeyLookup where HierarchyID = @HierarchyID
				delete from app.HierarchyBinKeyLookupLog where HierarchyID = @HierarchyID

				delete from app.Hierarchy where HierarchyID = @HierarchyID
				delete from app.HierarchyLog where HierarchyID = @HierarchyID
			if @TranCount = 0 commit tran
		end
end try
begin catch	
	if @TranCount = 0 and @@trancount > 0 rollback tran	
	exec app.ReThrowError
end catch
GO
