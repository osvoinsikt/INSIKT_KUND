SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [insikt].[FCProject_Inserting]
(
	@FCProjectID int
	,@ParentEventID int = null
)
as
begin try
	--
	-- Standardvariabler
	--
	declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
	set @ProcName = app.GetObjectFullName(@@procid)
	set @TranCount = @@trancount

    --------------------------------------------------------------------------
    -- Start
    --------------------------------------------------------------------------
	declare @LogDescription nvarchar(max),@EventName nvarchar(50)
    select @LogDescription = 'Nytt projekt håller på att skapas'

    exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
            ,@EventTitle = 'FCProject_Inserting'
            ,@Description = @LogDescription
	
	declare @Status int = 1
			,@Message nvarchar(max) = ''

	select
		[Status] = @Status
		,[Message] = @Message

	exec app.LogEventStop @EventIDStack = @EventIDStack out
	--------------------------------------------------------------------------
	-- Stop
	--------------------------------------------------------------------------
end try
begin catch
	--
	-- Roll back any transactions and log errors
	--
	if @TranCount = 0 and @@trancount > 0 rollback tran
	exec app.HandleProcError @EventIDStack out, @ParentEventID, @ProcName
	exec app.ReThrowError
end catch

GO
