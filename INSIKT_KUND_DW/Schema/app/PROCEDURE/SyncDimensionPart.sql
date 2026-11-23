SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[SyncDimensionPart]
(
	@DimensionPartTypeID int
	,@InputTable sysname
	,@ChangesBy nvarchar(50) = null
	,@Filter nvarchar(4000) = null
	,@DeleteMethod int = null
	,@Debug bit = 0
	,@ParentEventID int = null
) as
set nocount on

-- SET XACT_ABORT ON will cause the transaction to be uncommittable
-- when the constraint violation occurs and other runtime errors occure. 
set xact_abort on;

--
-- Save proceudre name and number of transactions to local variables @ProcName and @TranCount
-- The reason of @ProcName is to ease copy paste between procedures.
--
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount

begin try
	

	declare @JoinColumns nvarchar(max)
	declare @DimensionPartTable varchar(512)
	declare @TargetFiler nvarchar(max)
	declare @DimensionPartTypeName nvarchar(100)
	declare @AddNullMembers bit
	select
		@DimensionPartTable = app.GetDimensionPartTableName(t.DimensionPartTypeID)
		,@TargetFiler = 
			case 
				when t.AddNullMembers = 1 then 
					quotename(isnull(parsename(t.IDColumnName, 1), t.Name + 'ID')) + ' >= 0' + 
					isnull(' and (' + nullif(@Filter, '') + ')', '')
				else 
					@Filter 
				end 
		,@DimensionPartTypeName = t.Name
		,@AddNullMembers = t.AddNullMembers
	from
		app.DimensionPartType t
	where
		t.DimensionPartTypeID = @DimensionPartTypeID
		
	if @@rowcount = 0		
		raiserror('DimensionPartTypeID %i does not exist.', 16, 10, @DimensionPartTypeID)
			
	if isnull(@Debug, 0) = 0
		exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output
			,@EventObject = @ProcName
			,@EventTitle = @DimensionPartTypeName
			,@Description = null


	set	@JoinColumns = '[Code]'

	select
		@JoinColumns = @JoinColumns + ',' + quotename(k.ColumnName)
	from
		app.DimensionPartType t
			inner join app.showDimensionPartTypeKeys k on
				k.DimensionPartTypeID = t.DimensionPartTypeID						
	where
		t.DimensionPartTypeID = @DimensionPartTypeID
		and isnull(parsename(t.IDColumnName, 1), t.Name + 'ID') <> k.ColumnName
	order by
		k.KeyNr	


	


	if @TranCount = 0 begin tran

	declare @RowsAffected int
	
	exec @RowsAffected = app.SyncTable  
		@SourceTable = @InputTable
		,@TargetTable = @DimensionPartTable
		,@JoinColumns = @JoinColumns
		,@DeleteMode = @DeleteMethod
		,@TargetFilter = @TargetFiler
		,@SynchronizedBy = @ChangesBy		
		,@SupressWarnings = 1
		,@Debug = @Debug
	if @AddNullMembers = 1
		begin 
			if isnull(@Debug, 0) = 0
				exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
					,@EventTitle = 'Add null members'					
					
			exec [app].[AddNullDimensionPartMembers]
				@DimensionPartTypeID = @DimensionPartTypeID
				,@Debug = @Debug
				
			if isnull(@Debug, 0) = 0		
				exec app.LogEventStop @EventIDStack = @EventIDStack out
		end
	
	
	if @TranCount = 0 commit tran	
	
	declare @EventDescription nvarchar(1000)
	select @EventDescription = 'Rows affected: ' + cast(@RowsAffected as varchar(12))

	if isnull(@Debug, 0) = 0		
		exec app.LogEventStop @EventIDStack = @EventIDStack out,
			@Description = @EventDescription
end try
begin catch	
	--
	-- Rollback transactions and log errors
	--
	if @TranCount = 0 and @@trancount > 0 rollback tran
	exec app.HandleProcError @EventIDStack out, @ParentEventID, @ProcName
	exec app.ReThrowError
end catch
GO
