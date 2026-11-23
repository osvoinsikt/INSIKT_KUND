SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Author:		TRIMMA Affärsutveckling AB
-- Description:	Procedur för att ladda hierarkier
-- ==========================================================================================
-- LOG:
--	2013-03-26, TRIMMA	Standardimplementation
-- ==========================================================================================
create procedure [dbo].[ETL_Hierarchies]
(
	@Type nvarchar(4000) = null
	,@ParamList nvarchar(4000) = null	
	,@ParentEventID int = null
)
as
--
-- Standardvariabler
--
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount


begin try
	--------------------------------------------------------------------------
	-- Start
	--------------------------------------------------------------------------
	exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
			,@EventTitle = 'ETL Hierarchies'
			,@Description = ''
			
			
		--------------------------------------------------------------------------
		-- Ladda samtliga konfigurerade och aktiverade dimensionsmotorhierarkier
		--------------------------------------------------------------------------		
		declare 
			@HierarchyID int
			,@SQL_LoadHierarchy nvarchar(max)
			
		select @HierarchyID = min(HierarchyID) from app.Hierarchy
		while @HierarchyID is not null
			begin
				if object_id(app.GetHierarchyLoadProcName(@HierarchyID)) is not null
					begin
						select @SQL_LoadHierarchy = 
							'exec ' + app.GetHierarchyLoadProcName(@HierarchyID) + ' @ParentEventID = ' + cast(cast(@EventIDStack as int) as nvarchar(12))
						exec (@SQL_LoadHierarchy)
					end
				select @HierarchyID = min(HierarchyID) from app.Hierarchy where HierarchyID > @HierarchyID
			end
		--------------------------------------------------------------------------
		
		
	exec app.LogEventStop @EventIDStack = @EventIDStack out
	-- Stop
	--------------------------------------------------------------------------
	
end try
begin catch	
	--
	-- Rulla tillbaka eventualla transaktioner startade i den här procedurn och logga fel.
	--
	if @TranCount = 0 and @@trancount > 0 rollback tran
	exec app.HandleProcError @EventIDStack out, @ParentEventID, @ProcName
	exec app.ReThrowError
end catch
GO
